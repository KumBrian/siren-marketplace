// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// OLD ARCHITECTURE IMPORTS (Keep temporarily)
import 'bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'bloc/cubits/products_cubit/products_cubit.dart';
import 'bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'core/constants/app_colors.dart';
import 'core/data/services/seeder.dart';
import 'core/di/injector.dart' as OldDI;
import 'features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'features/buyer/logic/buyer_orders_bloc/buyer_orders_bloc.dart';
import 'features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'features/user/logic/notifications_cubit/notifications_cubit.dart'
    as OldNotifications;
import 'features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'features/user/logic/user_bloc/user_bloc.dart';
// NEW ARCHITECTURE IMPORTS
import 'new_core/config/app_config.dart';
import 'new_core/di/injection.dart' as NewDI;
import 'new_core/presentation/cubits/auth/auth_cubit.dart';
import 'new_core/presentation/cubits/expiration/expiration_cubit.dart';
import 'new_core/presentation/cubits/notification/notification_cubit.dart';
import 'router.dart';

// Temporary demo user IDs (will be managed by AuthCubit)
const String CURRENT_FISHER_ID = 'fisher-1'; // Using new demo data
const String CURRENT_BUYER_ID = 'buyer-1'; // Using new demo data

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🆕 Initialize NEW DI System
  AppConfig.setMode(DataSourceMode.demo);
  await NewDI.DI().init();

  // 🔴 Keep OLD DI System (temporarily)
  await OldDI.initDependencies();

  // 🔴 Seed OLD database (temporarily - will use new demo data later)
  await CatchSeeder().seedAll();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ============================================================
        // 🆕 NEW ARCHITECTURE - Global BLoCs
        // ============================================================
        BlocProvider(create: (_) => AuthCubit()..initialize()),
        BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(create: (_) => ExpirationCubit()..startPeriodicCheck()),

        // ============================================================
        // 🔴 OLD ARCHITECTURE - Keep temporarily for existing screens
        // ============================================================
        BlocProvider.value(
          value: OldDI.sl<UserBloc>()..add(const LoadPrimaryUser()),
        ),
        BlocProvider.value(value: OldDI.sl<FisherCubit>()),
        BlocProvider.value(value: OldDI.sl<ConversationsBloc>()),
        BlocProvider(create: (_) => OldDI.sl<OffersBloc>()),
        BlocProvider(
          create: (_) => OldDI.sl<CatchesBloc>()..add(LoadCatches()),
        ),
        BlocProvider(create: (_) => OldDI.sl<CatchFilterCubit>()),
        BlocProvider(create: (_) => OldDI.sl<SpeciesFilterCubit>()),
        BlocProvider(create: (_) => OldDI.sl<BottomNavCubit>()),
        BlocProvider(create: (_) => OldDI.sl<OrdersFilterCubit>()),
        BlocProvider(create: (_) => OldDI.sl<FailedTransactionCubit>()),
        BlocProvider(create: (_) => OldDI.sl<ProductsFilterCubit>()),
        BlocProvider(create: (_) => OldDI.sl<OffersFilterCubit>()),
        BlocProvider(
          create: (_) => OldDI.sl<OldNotifications.NotificationsCubit>(),
        ),
        BlocProvider(create: (_) => OldDI.sl<ReviewsCubit>()),
        BlocProvider(create: (_) => OldDI.sl<ProductsCubit>()),
        BlocProvider(create: (context) => OldDI.sl<FilteredProductsCubit>()),
        BlocProvider(create: (_) => OldDI.sl<OfferDetailsBloc>()),
        BlocProvider(
          create: (_) => OldDI.sl<BuyerMarketBloc>()..add(LoadMarketCatches()),
        ),
        BlocProvider(
          create: (_) =>
              OldDI.sl<BuyerOrdersBloc>()
                ..add(LoadBuyerOrders(CURRENT_BUYER_ID)),
        ),
        BlocProvider(
          create: (_) =>
              OldDI.sl<BuyerCubit>()..loadBuyerData(buyerId: CURRENT_BUYER_ID),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            // Pass both old UserBloc and new AuthCubit to router
            routerConfig: createRouter(
              context.read<UserBloc>(),
              context.read<AuthCubit>(),
            ),
          );
        },
      ),
    );
  }
}
