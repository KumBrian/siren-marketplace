import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Blocs & Cubits
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
// Core
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/data/services/seeder.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/features/buyer/data/buyer_repository.dart';
// Features
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_orders_bloc/buyer_orders_bloc.dart';
import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
// Repositories
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offer_bloc/offer_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/order_bloc/order_bloc.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart';
// Router
import 'package:siren_marketplace/router.dart';

const String CURRENT_FISHER_ID = 'fisher_id_1';
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
        // General Cubits
        BlocProvider(create: (_) => CatchFilterCubit()),
        BlocProvider(create: (_) => SpeciesFilterCubit()),
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => OrdersFilterCubit()),
        BlocProvider(create: (_) => FailedTransactionCubit()),
        BlocProvider(create: (_) => ProductsFilterCubit()),

        // Core DI-provided Blocs
        BlocProvider(
          create: (_) => sl<UserBloc>()..add(const LoadPrimaryUser()),
        ),
        BlocProvider(
          create: (_) => FisherCubit(repository: sl<FisherRepository>()),
        ),
        BlocProvider(create: (_) => ProductsCubit(sl<CatchRepository>())),
        BlocProvider(
          create: (context) => FilteredProductsCubit(
            catchRepository: sl<CatchRepository>(),
            filterCubit: context.read<ProductsFilterCubit>(),
          ),
        ),

        // Fisher Feature
        BlocProvider(
          create: (_) => CatchesBloc(sl<CatchRepository>())..add(LoadCatches()),
        ),
        BlocProvider(create: (_) => OffersBloc(sl<OfferRepository>())),
        BlocProvider(
          create: (_) => OrdersBloc(
            sl<OrderRepository>(),
            sl<OfferRepository>(),
            sl<UserRepository>(),
          )..add(const LoadAllFisherOrders(userId: CURRENT_FISHER_ID)),
        ),

        // Buyer Feature
        BlocProvider(
          create: (_) =>
              BuyerMarketBloc(sl<BuyerRepository>())..add(LoadMarketCatches()),
        ),
        BlocProvider(
          create: (_) =>
              BuyerOrdersBloc(sl<BuyerRepository>())
                ..add(LoadBuyerOrders(CURRENT_BUYER_ID)),
        ),
        BlocProvider(
          create: (_) => BuyerCubit(
            sl<UserRepository>(),
            sl<OrderRepository>(),
            sl<OfferRepository>(),
          )..loadBuyerData(buyerId: CURRENT_BUYER_ID),
        ),

        // Chat Feature
        BlocProvider(
          create: (_) =>
              ConversationsBloc(sl<ConversationRepository>())
                ..add(const LoadConversations(buyerId: CURRENT_BUYER_ID)),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<CatchesBloc, CatchesState>(
            listener: (context, state) {
              if (state is CatchesLoaded) {
                final catchIds = state.catches.map((c) => c.id).toList();
                context.read<OffersBloc>().add(LoadAllFisherOffers(catchIds));
              }
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
              ),
              routerConfig: createRouter(context.read<UserBloc>()),
            ),
          );
        },
      ),
    );
  }
}
