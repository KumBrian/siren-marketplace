// ============================================================================
// UNIFIED DEPENDENCY INJECTION USING GET_IT
// ============================================================================
import 'package:get_it/get_it.dart';
// Cubits / Blocs (Second file)
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
// DB, Notifier, Feature Repos
import 'package:siren_marketplace/core/data/database/database_helper.dart';
// import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';

import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/orders_bloc/orders_cubit.dart';

import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_cubit/user_cubit.dart';

import '../config/app_config.dart';
import '../data/datasources/demo/demo_datasource.dart';
import '../data/datasources/local/local_datasource_factory.dart';
import '../data/repositories/catch_repository_impl.dart';
import '../data/repositories/offer_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/i_catch_repository.dart';
import '../domain/repositories/i_offer_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../domain/repositories/i_review_repository.dart';
import '../domain/repositories/i_session_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/services/expiration_service.dart';
import '../domain/services/marketplace_service.dart';
import '../domain/services/negotiation_service.dart';
import '../domain/services/order_service.dart';
import '../domain/services/rating_service.dart';
import '../domain/services/session_service.dart';

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
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  sl.registerLazySingleton(() => dbHelper);
  sl.registerLazySingleton(() => TransactionNotifier());

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
      throw UnimplementedError("API mode not implemented");
  }

  // --------------------------------------------------
  // Register Services (use repositories)
  // --------------------------------------------------
  sl.registerLazySingleton(
    () => NegotiationService(
      offerRepository: sl(),
      orderRepository: sl(),
      catchRepository: sl(),
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
    () => SessionService(sessionRepository: sl(), userRepository: sl()),
  );

  // --------------------------------------------------
  // Register UIs: Cubits & Blocs From Second File
  // --------------------------------------------------
  _initCubitsAndBlocs();
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

  // Feature-layer repos (from second DI file)
  // Note: In a full refactor, these should also use IRepository interfaces
  sl.registerLazySingleton(() => ConversationRepository(dbHelper: sl()));
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

  // Feature-layer repos
  sl.registerLazySingleton(() => ConversationRepository(dbHelper: sl()));
}

// ============================================================================
// CUBITS & BLOCS FROM SECOND FILE
// ============================================================================
void _initCubitsAndBlocs() {
  // Global Singletons
  sl.registerLazySingleton(() => OffersFilterCubit());
  sl.registerLazySingleton(() => FailedTransactionCubit());

  sl.registerLazySingleton(
    () => CatchesCubit(repository: sl<ICatchRepository>()),
  );

  sl.registerLazySingleton(
    () => OffersCubit(
      repository: sl<IOfferRepository>(),
      negotiationService: sl<NegotiationService>(),
    ),
  );

  sl.registerLazySingleton(
    () => OrdersCubit(
      orderRepository: sl<IOrderRepository>(),
      offerRepository: sl<IOfferRepository>(),
      catchRepository: sl<ICatchRepository>(),
      ratingService: sl<RatingService>(),
    ),
  );

  // Factories (per view)
  sl.registerFactory(() => ReviewsCubit(sl(), sl()));
  sl.registerFactory(
    () => UserCubit(userRepository: sl(), reviewRepository: sl()),
  );
  sl.registerFactory(() => ConversationsBloc(sl()));
}
