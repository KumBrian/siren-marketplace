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
  // Repositories
  // ----------------------------
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<FisherRepository>(() => FisherRepository());
  sl.registerLazySingleton<CatchRepository>(() => CatchRepository());
  sl.registerLazySingleton<OfferRepository>(() => OfferRepository());
  sl.registerLazySingleton<OrderRepository>(() => OrderRepository());
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(dbHelper: sl()),
  );
  sl.registerLazySingleton<BuyerRepository>(() => BuyerRepository());

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
  sl.registerFactory(() => UserBloc(userRepository: sl()));
  sl.registerFactory(() => CatchesBloc(sl<CatchRepository>()));
  sl.registerFactory(() => OffersBloc(sl<OfferRepository>()));
  sl.registerFactory(
    () => OrdersBloc(
      sl<OrderRepository>(),
      sl<OfferRepository>(),
      sl<UserRepository>(),
    ),
  );
  sl.registerFactory(() => BuyerMarketBloc(sl<BuyerRepository>()));
  sl.registerFactory(() => BuyerOrdersBloc(sl<BuyerRepository>()));
  sl.registerFactory(() => ConversationsBloc(sl<ConversationRepository>()));
}
