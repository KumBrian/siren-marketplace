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

import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/user/logic/notifications_cubit/notifications_cubit.dart';
import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_cubit/user_cubit.dart';
import 'package:siren_marketplace/router.dart';

import 'features/fisher/logic/catches_bloc/catches_cubit.dart';
import 'features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'features/fisher/logic/orders_bloc/orders_cubit.dart';

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
        BlocProvider.value(value: sl<UserCubit>()),
        BlocProvider.value(value: sl<ConversationsBloc>()),
        BlocProvider(create: (_) => sl<CatchesCubit>()),
        BlocProvider(create: (_) => sl<OffersCubit>()),
        BlocProvider(create: (_) => sl<OrdersCubit>()),
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
            routerConfig: createRouter(context.read<UserCubit>()),
          );
        },
      ),
    );
  }
}
