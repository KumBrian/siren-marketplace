import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/product_cubit/product_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/data/mock_repo.dart';
import 'package:siren_marketplace/router.dart';

import 'bloc/cubits/role_cubit.dart';
import 'data/data_repo.dart';

void main() {
  final repository = MockRepositoryImpl();
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final Repository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CatchFilterCubit()),
        BlocProvider(create: (_) => SpeciesFilterCubit()),
        BlocProvider(create: (_) => ProductsFilterCubit()),
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => OrdersFilterCubit()),
        BlocProvider(create: (_) => FailedTransactionCubit()),
        BlocProvider<UserRoleCubit>(
          // OLD: create: (_) => UserRoleCubit(repository)..loadRole(),
          // NEW: Only initialize the cubit, do not automatically call loadRole()
          create: (_) => UserRoleCubit(repository),
        ),
        BlocProvider<FisherCubit>(
          create: (_) => FisherCubit(repository)..loadFisher(),
        ),
        BlocProvider<BuyerCubit>(
          create: (_) => BuyerCubit(repository)..loadBuyer(),
        ),
        BlocProvider<ProductCubit>(
          create: (_) => ProductCubit(repository)..loadProducts(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Provide router with correct refreshListenable
          final roleCubit = context.read<UserRoleCubit>();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
            ),
            routerConfig: createRouter(roleCubit), // pass roleCubit to router
          );
        },
      ),
    );
  }
}
