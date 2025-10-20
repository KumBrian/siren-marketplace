import 'package:get_it/get_it.dart';
// Blocs/Cubits
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
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
import 'package:siren_marketplace/features/fisher/logic/offer_bloc/offer_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/order_bloc/order_bloc.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ----------------------------
  // Database
  // ----------------------------
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  sl.registerLazySingleton(() => dbHelper);

  // ----------------------------
  // Repositories (MUST take dbHelper in constructor)
  // ----------------------------
  // Registering repositories with the injected DatabaseHelper
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<FisherRepository>(
    () => FisherRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<CatchRepository>(
    () => CatchRepository(dbHelper: sl(), offerRepository: sl()),
  );
  sl.registerLazySingleton<OfferRepository>(
    () => OfferRepository(dbHelper: sl()),
  );
  // OrderRepository takes other repositories as dependencies
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
  // FIX 1: Change UserBloc to LazySingleton if its state needs to persist across the app's lifetime.
  // Assuming User state should persist:
  sl.registerLazySingleton(() => UserBloc(userRepository: sl()));

  // FIX 2: Change OrdersBloc to LazySingleton so its state (OrdersLoaded) persists on navigation.
  sl.registerLazySingleton(
    () => OrdersBloc(
      sl<OrderRepository>(),
      sl<OfferRepository>(),
      sl<UserRepository>(),
      sl<CatchRepository>(),
    ),
  );

  // Consider changing these too if their state needs to persist across navigation/screens:
  // sl.registerLazySingleton(() => CatchesBloc(sl<CatchRepository>()));
  // sl.registerLazySingleton(() => OffersBloc(sl<OfferRepository>()));

  // Keeping these as Factory as they might be scoped per screen or flow, but
  // typically if a bloc is used in MultiBlocProvider at the root, LazySingleton is better.
  sl.registerFactory(() => CatchesBloc(sl<CatchRepository>()));
  sl.registerFactory(() => OffersBloc(sl<OfferRepository>()));
  sl.registerFactory(() => BuyerMarketBloc(sl<BuyerRepository>()));
  sl.registerFactory(
    () => OfferDetailsBloc(
      sl<OfferRepository>(),
      sl<CatchRepository>(),
      sl<UserRepository>(),
    ),
  );
  sl.registerFactory(() => BuyerOrdersBloc(sl<BuyerRepository>()));
  sl.registerFactory(() => ConversationsBloc(sl<ConversationRepository>()));
}
