import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Blocs & Cubits
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/services/seeder.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_orders_bloc/buyer_orders_bloc.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/notifications_cubit/notifications_cubit.dart';
import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';
import 'package:siren_marketplace/router.dart';

const String CURRENT_FISHER_ID = 'fisher_id_2';
const String CURRENT_BUYER_ID = 'buyer_id_1';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI
  await initDependencies();

  // Seed database
  await CatchSeeder().seedAll();

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<UserBloc>()..add(const LoadPrimaryUser())),
        BlocProvider.value(value: sl<FisherCubit>()),
        BlocProvider.value(value: sl<ConversationsBloc>()),
        BlocProvider(create: (_) => sl<OffersBloc>()),
        BlocProvider(create: (_) => sl<CatchesBloc>()..add(LoadCatches())),
        BlocProvider(create: (_) => sl<CatchFilterCubit>()),
        BlocProvider(create: (_) => sl<SpeciesFilterCubit>()),
        BlocProvider(create: (_) => sl<BottomNavCubit>()),
        BlocProvider(create: (_) => sl<OrdersFilterCubit>()),
        BlocProvider(create: (_) => sl<FailedTransactionCubit>()),
        BlocProvider(create: (_) => sl<ProductsFilterCubit>()),
        BlocProvider(create: (_) => sl<OffersFilterCubit>()),
        BlocProvider(create: (_) => sl<NotificationsCubit>()),
        BlocProvider(create: (_) => sl<ReviewsCubit>()),
        BlocProvider(create: (_) => sl<ProductsCubit>()),
        BlocProvider(create: (context) => sl<FilteredProductsCubit>()),

        BlocProvider(create: (_) => sl<OfferDetailsBloc>()),
        BlocProvider(
          create: (_) => sl<BuyerMarketBloc>()..add(LoadMarketCatches()),
        ),
        BlocProvider(
          create: (_) =>
              sl<BuyerOrdersBloc>()..add(LoadBuyerOrders(CURRENT_BUYER_ID)),
        ),
        BlocProvider(
          create: (_) =>
              sl<BuyerCubit>()..loadBuyerData(buyerId: CURRENT_BUYER_ID),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
              appBarTheme: AppBarTheme(centerTitle: true),
            ),
            // Passing the singleton UserBloc instance to the router
            routerConfig: createRouter(context.read<UserBloc>()),
          );
        },
      ),
    );
  }
}
