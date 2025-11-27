// ============================================================================
// UNIFIED DEPENDENCY INJECTION USING GET_IT
// ============================================================================
import 'package:get_it/get_it.dart';
// Cubits / Blocs (Second file)
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
// DB, Notifier, Feature Repos
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';

import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/orders_bloc/orders_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/users_bloc/users_cubit.dart';
import 'package:siren_marketplace/features/user/logic/notifications_cubit/notifications_cubit.dart';
import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

import '../config/app_config.dart';
import '../data/datasources/demo/demo_datasource.dart';
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
      throw UnimplementedError("Local mode not implemented");

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
    () => OrderService(
      orderRepository: sl(),
      offerRepository: sl(),
      catchRepository: sl(),
    ),
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
  sl.registerLazySingleton(() => UserRepository(dbHelper: sl()));
  sl.registerLazySingleton(() => FisherRepository(dbHelper: sl()));
  sl.registerLazySingleton(() => ConversationRepository(dbHelper: sl()));
}

// ============================================================================
// CUBITS & BLOCS FROM SECOND FILE
// ============================================================================
void _initCubitsAndBlocs() {
  // Global Singletons
  sl.registerLazySingleton(() => BottomNavCubit());
  sl.registerLazySingleton(() => CatchFilterCubit());
  sl.registerLazySingleton(() => SpeciesFilterCubit());
  sl.registerLazySingleton(() => OrdersFilterCubit());
  sl.registerLazySingleton(() => ProductsFilterCubit());
  sl.registerLazySingleton(() => OffersFilterCubit());
  sl.registerLazySingleton(() => FailedTransactionCubit());
  sl.registerLazySingleton(() => NotificationsCubit());

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
      ratingService: sl<RatingService>(),
    ),
  );

  sl.registerLazySingleton(() => UsersCubit(repository: sl<IUserRepository>()));

  // Factories (per view)
  sl.registerFactory(() => ProductsCubit(sl()));
  sl.registerFactory(
    () => FilteredProductsCubit(catchRepository: sl(), filterCubit: sl()),
  );

  sl.registerFactory(() => FisherCubit(repository: sl()));
  sl.registerFactory(() => ReviewsCubit(sl(), sl()));
  sl.registerFactory(() => UserBloc(userRepository: sl()));
  sl.registerFactory(() => ConversationsBloc(sl()));
}
