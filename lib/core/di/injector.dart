import 'package:get_it/get_it.dart'; // Blocs/Cubits
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:siren_marketplace/features/buyer/data/buyer_repository.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_orders_bloc/buyer_orders_bloc.dart';
import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/orders_bloc/orders_bloc.dart';
import 'package:siren_marketplace/features/user/data/review_repository.dart';
import 'package:siren_marketplace/features/user/logic/notifications_cubit/notifications_cubit.dart';
import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ----------------------------
  // Database
  // ----------------------------
  final dbHelper = DatabaseHelper();
  final transactionNotifier = TransactionNotifier();
  sl.registerLazySingleton(() => transactionNotifier);
  await dbHelper.database;
  sl.registerLazySingleton(() => dbHelper);

  // ----------------------------
  // Repositories
  // ----------------------------
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<FisherRepository>(
    () => FisherRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<OfferRepository>(
    () => OfferRepository(dbHelper: sl(), notifier: sl<TransactionNotifier>()),
  );
  sl.registerLazySingleton<CatchRepository>(
    () => CatchRepository(
      dbHelper: sl(),
      offerRepository: sl(),
      notifier: sl<TransactionNotifier>(),
    ),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepository(
      dbHelper: sl(),
      offerRepository: sl(),
      fisherRepository: sl(),
    ),
  );
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<BuyerRepository>(
    () => BuyerRepository(dbHelper: sl()),
  );

  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepository(sl()));

  // ----------------------------
  // Cubits
  // ----------------------------
  sl.registerLazySingleton(() => BottomNavCubit());
  sl.registerLazySingleton(() => CatchFilterCubit());
  sl.registerLazySingleton(() => SpeciesFilterCubit());
  sl.registerLazySingleton(() => OrdersFilterCubit());
  sl.registerLazySingleton(() => FailedTransactionCubit());
  sl.registerLazySingleton(() => ProductsCubit(sl<CatchRepository>()));
  sl.registerLazySingleton(() => ProductsFilterCubit());
  sl.registerLazySingleton(() => OffersFilterCubit());
  sl.registerLazySingleton(() => NotificationsCubit());
  sl.registerLazySingleton(
    () => ReviewsCubit(sl<ReviewRepository>(), sl<UserRepository>()),
  );
  sl.registerLazySingleton(
    () => FilteredProductsCubit(
      catchRepository: sl<CatchRepository>(),
      filterCubit: sl<ProductsFilterCubit>(),
    ),
  );
  sl.registerLazySingleton(
    () => FisherCubit(repository: sl<FisherRepository>()),
  );
  sl.registerLazySingleton(
    () => BuyerCubit(
      sl<UserRepository>(),
      sl<OrderRepository>(),
      sl<OfferRepository>(),
    ),
  );

  // ----------------------------
  // Blocs
  // ----------------------------
  sl.registerLazySingleton(() => UserBloc(userRepository: sl()));
  sl.registerFactory(
    () => OrdersBloc(
      orderRepository: sl<OrderRepository>(),
      offerRepository: sl<OfferRepository>(),
      notifier: sl<TransactionNotifier>(),
    ),
  );

  sl.registerFactory(() => CatchesBloc(sl<CatchRepository>()));
  sl.registerFactory(
    () => OffersBloc(
      offerRepository: sl<OfferRepository>(),
      notifier: sl<TransactionNotifier>(),
      catchRepository: sl<CatchRepository>(), // NEW
      userRepository: sl<UserRepository>(), // NEW
    ),
  );
  sl.registerFactory(() => BuyerMarketBloc(sl<BuyerRepository>()));
  sl.registerFactory(
    () => OfferDetailsBloc(
      sl<OfferRepository>(),
      sl<CatchRepository>(),
      sl<UserRepository>(),
      sl<OrderRepository>(),
    ),
  );
  sl.registerFactory(() => BuyerOrdersBloc(sl<BuyerRepository>()));
  sl.registerFactory(() => ConversationsBloc(sl<ConversationRepository>()));
}
