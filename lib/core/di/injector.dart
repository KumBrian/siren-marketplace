// ============================================================================
// UNIFIED DEPENDENCY INJECTION USING GET_IT
// ============================================================================
import 'package:get_it/get_it.dart';
// DB, Notifier, Feature Repos
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';

import '../config/app_config.dart';
import '../data/datasources/demo/demo_datasource.dart';
import '../data/datasources/local/local_conversation_datasource.dart';
import '../data/datasources/local/local_datasource_factory.dart';
import '../data/datasources/local/local_message_datasource.dart';
import '../data/datasources/api/catches_api_data_source.dart';
import '../data/datasources/api/media_api_data_source.dart';
import '../data/datasources/api/offers_api_data_source.dart';
import '../data/datasources/api/user_api_datasource.dart';
import '../data/api/api_config.dart';

import 'package:dio/dio.dart';
import '../data/repositories/catch_repository_impl.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../data/repositories/message_repository_impl.dart';
import '../data/repositories/offer_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/i_catch_repository.dart';
import '../domain/repositories/i_conversation_repository.dart';
import '../domain/repositories/i_message_repository.dart';
import '../domain/repositories/i_offer_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../domain/repositories/i_review_repository.dart';
import '../domain/repositories/i_session_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/services/expiration_service.dart';
import '../domain/services/marketplace_service.dart';
import '../domain/services/message_service.dart';
import '../domain/services/negotiation_service.dart';
import '../domain/services/order_service.dart';
import '../domain/services/rating_service.dart';
import '../domain/services/session_service.dart';
import '../data/api/api_client.dart';
import '../data/storage/token_storage.dart';
import '../data/sources/api/auth_api_data_source.dart';

// ============================================================================
// GET_IT INSTANCE
// ============================================================================
final sl = GetIt.instance;

// ============================================================================
// UNIFIED INITIALIZER
// ============================================================================
Future<void> initDependencies() async {
  sl.reset(dispose: false);
  // --------------------------------------------------
  // Initialize DB + Core Dependencies
  // --------------------------------------------------
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton(() => TransactionNotifier());

  // --------------------------------------------------
  // API Dependencies (Always register these if configured)
  // --------------------------------------------------
  sl.registerLazySingleton(() => TokenStorage());

  // Register Core API Client
  sl.registerLazySingleton(
    () => ApiClient.core(tokenStorage: sl()),
    instanceName: 'coreApiClient',
  );

  // Register Marketplace API Client
  sl.registerLazySingleton(
    () => ApiClient.marketplace(tokenStorage: sl()),
    instanceName: 'marketplaceApiClient',
  );

  // Register Auth Data Source
  sl.registerLazySingleton<IAuthApiDataSource>(
    () => AuthApiDataSource(client: sl(instanceName: 'coreApiClient')),
  );

  // --------------------------------------------------
  // CHOOSE DATA SOURCE MODE (demo/local/api)
  // --------------------------------------------------
  switch (AppConfig.mode) {
    case DataSourceMode.demo:
      _initDemoMode();
      break;

    case DataSourceMode.local:
      _initLocalMode(dbHelper);
      break;

    case DataSourceMode.api:
      _initApiMode(dbHelper);
      break;
  }

  // --------------------------------------------------
  // Register Services (use repositories)
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => NegotiationService(
      offerRepository: sl(),
      orderRepository: sl(),
      catchRepository: sl(),
      messageService: sl(),
    ),
  );

  sl.registerLazySingleton(() => ExpirationService(catchRepository: sl()));

  sl.registerLazySingleton(
    () => RatingService(
      reviewRepository: sl(),
      orderRepository: sl(),
      userRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MarketplaceService(catchRepository: sl(), userRepository: sl()),
  );

  sl.registerLazySingleton(
    () => OrderService(orderRepository: sl(), catchRepository: sl()),
  );

  sl.registerLazySingleton(
    () => SessionService(
      sessionRepository: sl(),
      userRepository: sl(),
      authApiDataSource: sl.isRegistered<IAuthApiDataSource>()
          ? sl<IAuthApiDataSource>()
          : null,
      tokenStorage: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MessageService(
      messageRepository: sl(),
      conversationRepository: sl(),
      userRepository: sl(),
    ),
  );
}

// ============================================================================
// DEMO MODE
// ============================================================================
void _initDemoMode() {
  final demo = DemoDataSourceFactory.create();

  // Repositories from DI file #1
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(dataSource: demo.userDataSource),
  );

  sl.registerLazySingleton<ICatchRepository>(
    () => CatchRepositoryImpl(dataSource: demo.catchDataSource),
  );

  sl.registerLazySingleton<IOfferRepository>(
    () => OfferRepositoryImpl(dataSource: demo.offerDataSource),
  );

  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(dataSource: demo.orderDataSource),
  );

  sl.registerLazySingleton<IReviewRepository>(
    () => ReviewRepositoryImpl(dataSource: demo.reviewDataSource),
  );

  sl.registerLazySingleton<ISessionRepository>(
    () => SessionRepositoryImpl(dataSource: demo.sessionDataSource),
  );

  // TODO: Add demo data sources for messaging when needed
  // For now, messaging will use local data sources even in demo mode
  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      dataSource: LocalMessageDataSource(dbHelper: sl()),
    ),
  );

  sl.registerLazySingleton<IConversationRepository>(
    () => ConversationRepositoryImpl(
      dataSource: LocalConversationDataSource(dbHelper: sl()),
    ),
  );
}

// ============================================================================
// LOCAL MODE
// ============================================================================
// ============================================================================
// LOCAL MODE
// ============================================================================
void _initLocalMode(DatabaseHelper dbHelper) {
  final local = LocalDataSourceFactory.create(dbHelper);

  // Register Repositories with Local Data Sources
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(dataSource: local.userDataSource),
  );

  sl.registerLazySingleton<ICatchRepository>(
    () => CatchRepositoryImpl(dataSource: local.catchDataSource),
  );

  sl.registerLazySingleton<IOfferRepository>(
    () => OfferRepositoryImpl(dataSource: local.offerDataSource),
  );

  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(dataSource: local.orderDataSource),
  );

  sl.registerLazySingleton<IReviewRepository>(
    () => ReviewRepositoryImpl(dataSource: local.reviewDataSource),
  );

  sl.registerLazySingleton<ISessionRepository>(
    () => SessionRepositoryImpl(dataSource: local.sessionDataSource),
  );

  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      dataSource: LocalMessageDataSource(dbHelper: dbHelper),
    ),
  );

  sl.registerLazySingleton<IConversationRepository>(
    () => ConversationRepositoryImpl(
      dataSource: LocalConversationDataSource(dbHelper: dbHelper),
    ),
  );
}

// ============================================================================
// API MODE
// ============================================================================
void _initApiMode(DatabaseHelper dbHelper) {
  // Initialize local data sources for fallback/caching
  final local = LocalDataSourceFactory.create(dbHelper);

  // API Clients are already registered globally in initDependencies

  // Register User Repository with API Data Source
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(
      dataSource: UserApiDataSource(client: sl(instanceName: 'coreApiClient')),
    ),
  );

  // Register Media API Data Source for Pulsebox
  sl.registerLazySingleton<MediaApiDataSource>(() {
    // Create separate Dio instance for Pulsebox
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.pulseboxBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return MediaApiDataSource(dio: dio, tokenStorage: sl<TokenStorage>());
  });

  // Register Catches Repository with API Data Source
  sl.registerLazySingleton<ICatchRepository>(
    () => CatchRepositoryImpl(
      dataSource: CatchesApiDataSource(
        client: sl(instanceName: 'marketplaceApiClient'),
        mediaDataSource: sl<MediaApiDataSource>(),
        speciesDataSource: SpeciesApiDataSource(
          client: sl(instanceName: 'marketplaceApiClient'),
        ),
      ),
    ),
  );

  sl.registerLazySingleton<IOfferRepository>(
    () => OfferRepositoryImpl(
      dataSource: OffersApiDataSource(
        client: sl(instanceName: 'marketplaceApiClient'),
      ),
    ),
  );

  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(dataSource: local.orderDataSource),
  );

  sl.registerLazySingleton<IReviewRepository>(
    () => ReviewRepositoryImpl(dataSource: local.reviewDataSource),
  );

  sl.registerLazySingleton<ISessionRepository>(
    () => SessionRepositoryImpl(dataSource: local.sessionDataSource),
  );

  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      dataSource: LocalMessageDataSource(dbHelper: dbHelper),
    ),
  );

  sl.registerLazySingleton<IConversationRepository>(
    () => ConversationRepositoryImpl(
      dataSource: LocalConversationDataSource(dbHelper: dbHelper),
    ),
  );
}
