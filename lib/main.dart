import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Blocs & Cubits
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/core/config/app_config.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/services/seeder.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';

import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_cubit/user_cubit.dart';

import 'features/fisher/logic/catches_bloc/catches_cubit.dart';
import 'features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'features/fisher/logic/orders_bloc/orders_cubit.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/providers/router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI
  await initDependencies();

  // Seed database if in local mode
  if (AppConfig.isLocalMode) {
    final seeder = Seeder();
    await seeder.seedAll();
  }

  // Run app
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<UserCubit>()),
        BlocProvider.value(value: sl<ConversationsBloc>()),
        BlocProvider(create: (_) => sl<CatchesCubit>()),
        BlocProvider(create: (_) => sl<OffersCubit>()),
        BlocProvider(create: (_) => sl<OrdersCubit>()),
        BlocProvider(create: (_) => sl<FailedTransactionCubit>()),
        BlocProvider(create: (_) => sl<OffersFilterCubit>()),

        BlocProvider(create: (_) => sl<ReviewsCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        routerConfig: router,
      ),
    );
  }
}
