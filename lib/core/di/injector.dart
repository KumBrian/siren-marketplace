// ============================================================================
// UNIFIED DEPENDENCY INJECTION USING GET_IT
// ============================================================================
import 'package:get_it/get_it.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
// DB, Notifier, Feature Repos
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/datasources/api/orders_api_data_source.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';

import '../config/app_config.dart';
import '../data/datasources/demo/demo_datasource.dart';
import '../data/datasources/local/local_conversation_datasource.dart';
import '../data/datasources/local/local_datasource_factory.dart';
import '../data/sources/api/auth_api_data_source.dart';
import '../data/datasources/api/catches_api_data_source.dart';
import '../data/datasources/api/offers_api_data_source.dart';
import '../data/datasources/api/orders_api_data_source.dart';
import '../data/datasources/api/reviews_api_data_source.dart';
import '../data/datasources/interfaces/i_catch_datasource.dart';
import '../data/datasources/interfaces/i_offer_datasource.dart';
import '../data/datasources/local/local_message_datasource.dart';
import '../data/datasources/api/media_api_data_source.dart';

import '../data/datasources/api/user_api_datasource.dart';
import '../data/datasources/api/products_api_data_source.dart';
import '../data/datasources/api/subgroups_api_data_source.dart';

import 'package:dio/dio.dart';
import '../data/repositories/catch_repository_impl.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../data/repositories/message_repository_impl.dart';
import '../data/repositories/offer_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/i_catch_repository.dart';
import '../domain/repositories/i_conversation_repository.dart';
import '../domain/repositories/i_message_repository.dart';
import '../domain/repositories/i_offer_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../domain/repositories/i_review_repository.dart';
import '../domain/repositories/i_session_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/repositories/i_product_repository.dart';
import '../domain/services/expiration_service.dart';
import '../domain/services/marketplace_service.dart';
import '../domain/services/message_service.dart';
import '../domain/services/negotiation_service.dart';
import '../domain/services/order_service.dart';
import '../domain/services/rating_service.dart';
import '../domain/services/session_service.dart';
import '../domain/services/viewed_offers_service.dart';
import '../data/api/api_client.dart';
import '../data/storage/token_storage.dart';
import '../data/sources/api/auth_api_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';

import '../providers/catch_providers.dart';
import '../providers/product_providers.dart';

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
  final viewedOffersService = ViewedOffersService();
  await viewedOffersService.init();
  sl.registerSingleton<IViewedOffersService>(viewedOffersService);

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
  sl.registerLazySingleton(
    () => ReviewsApiDataSource(sl(instanceName: 'marketplaceApiClient')),
  );
  sl.registerLazySingleton<IOfferDataSource>(
    () => OffersApiDataSource(
      client: sl(instanceName: 'marketplaceApiClient'),
      viewedOffersService: sl(),
    ),
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
      productRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => ExpirationService(catchRepository: sl()));

  sl.registerLazySingleton<RatingService>(
    () => RatingService(reviewRepository: sl(), orderRepository: sl()),
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
    () => CatchRepositoryImpl(
      remoteDataSource: demo.catchDataSource,
      localDataSource: demo.catchDataSource,
    ),
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

  sl.registerLazySingleton<IProductRepository>(
    () => _DemoProductRepository(sl()),
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
    () => CatchRepositoryImpl(
      remoteDataSource: local.catchDataSource,
      localDataSource: local.catchDataSource,
    ),
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

  sl.registerLazySingleton<IProductRepository>(
    () => _DemoProductRepository(sl()),
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
  // First register the data source as a singleton so we can set callbacks
  sl.registerLazySingleton<CatchesApiDataSource>(
    () => CatchesApiDataSource(
      client: sl(instanceName: 'marketplaceApiClient'),
      mediaDataSource: sl<MediaApiDataSource>(),
      subgroupsDataSource: sl<SubgroupsApiDataSource>(),
    ),
  );

  sl.registerLazySingleton<ICatchRepository>(
    () => CatchRepositoryImpl(
      remoteDataSource: sl<CatchesApiDataSource>(),
      localDataSource: local.catchDataSource,
    ),
  );

  sl.registerLazySingleton<IOfferRepository>(
    () => OfferRepositoryImpl(
      dataSource: OffersApiDataSource(
        client: sl(instanceName: 'marketplaceApiClient'),
        viewedOffersService: sl<IViewedOffersService>(),
      ),
    ),
  );

  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(
      dataSource: OrdersApiDataSource(
        client: sl(instanceName: 'marketplaceApiClient'),
      ),
    ),
  );

  sl.registerLazySingleton<IReviewRepository>(
    () => ReviewRepositoryImpl(
      dataSource: local.reviewDataSource,
      apiDataSource: sl<ReviewsApiDataSource>(),
    ),
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

  // Register Product Repository
  sl.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      ProductsApiDataSource(sl(instanceName: 'marketplaceApiClient')),
    ),
  );

  // Register Subgroups API Data Source
  sl.registerLazySingleton<SubgroupsApiDataSource>(
    () => SubgroupsApiDataSource(sl(instanceName: 'marketplaceApiClient')),
  );

  // Set up callback for catch published event
  // This will be called after ProviderScope is initialized
  _setupCatchPublishedCallback();
}

/// Set up callback for catch published to marketplace event
/// Must be called after ProviderScope is created in main()
void setupProviderInvalidation(ProviderContainer container) {
  // Import at top of file
  // import '../providers/provider_invalidator.dart';

  if (sl.isRegistered<CatchesApiDataSource>()) {
    final catchesDataSource = sl<CatchesApiDataSource>();

    // Set callback to invalidate both catch and product providers
    catchesDataSource.setOnCatchPublishedCallback(() {
      print(
        'DEBUG: Catch published callback triggered, invalidating providers',
      );
      container.invalidate(fisherCatchesProvider);
      container.invalidate(fisherProductsProvider);
    });

    print('DEBUG: Provider invalidation callback set up successfully');
  }
}

void _setupCatchPublishedCallback() {
  // This will be called later from main() after ProviderScope is created
  // For now, just log that we're in API mode
  print(
    'DEBUG: API mode initialized, provider callback will be set in setupProviderInvalidation()',
  );
}

// ============================================================================
// DEMO/LOCAL PRODUCT REPOSITORY ADAPTER
// ============================================================================
class _DemoProductRepository implements IProductRepository {
  final ICatchRepository _catchRepository;

  _DemoProductRepository(this._catchRepository);

  @override
  Future<Either<Failure, List<Product>>> getFisherProducts({
    int page = 1,
  }) async {
    // Basic implementation: fetch all catches for fisher, map to products
    return Right([]);
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    final catchItem = await _catchRepository.getById(id);
    if (catchItem == null) return Right(null);
    return Right(_mapCatchToProduct(catchItem));
  }

  @override
  Future<Either<Failure, List<Offer>>> getProductOffers(
    String productId,
  ) async {
    return Right([]);
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String id) async {
    await _catchRepository.delete(id);
    return Right(true);
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    String id, {
    required double pricePerKg,
    required double finalPrice,
    required double availableWeight,
  }) async {
    // Not implemented for demo offer creation flow
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getAvailableProducts() async {
    final catches = await _catchRepository.getAvailableCatches();
    return Right(catches.map(_mapCatchToProduct).toList());
  }

  Product _mapCatchToProduct(Catch catchItem) {
    return Product(
      id: catchItem.id,
      name: catchItem.name,
      marketName: catchItem.market,
      status: catchItem.status.name,
      pricePerKg: catchItem.pricePerKg,
      totalPrice: catchItem.totalPrice,
      initialWeight: catchItem.initialWeight,
      availableWeight: catchItem.availableWeight,
      size: catchItem.size,
      datePosted: catchItem.datePosted,
      locationName: catchItem.locationName,
      latitude: catchItem.latitude,
      longitude: catchItem.longitude,
      soldAt: null,
      isSold: false,
      gearNature: catchItem.gearNature,
      species: catchItem.species,
      offersCount: 0,
      images: catchItem.images,
      fisherId: catchItem.fisherId,
    );
  }
}
