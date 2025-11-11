import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/fisher.dart';
import 'package:siren_marketplace/features/user/presentation/screens/about.dart';
import 'package:siren_marketplace/features/user/presentation/screens/account_info.dart';
import 'package:siren_marketplace/features/user/presentation/screens/beaches.dart';
import 'package:siren_marketplace/features/user/presentation/screens/logout.dart';
import 'package:siren_marketplace/features/user/presentation/screens/projects.dart';
import 'package:siren_marketplace/features/user/presentation/screens/user_profile.dart';

import 'core/di/injector.dart';
import 'core/types/enum.dart';
import 'features/buyer/presentation/screens/buyer.dart';
import 'features/buyer/presentation/screens/congratulations_screen.dart';
import 'features/buyer/presentation/screens/notifications_screen.dart';
import 'features/buyer/presentation/screens/offer_details.dart';
import 'features/buyer/presentation/screens/order_details.dart';
import 'features/buyer/presentation/screens/orders_screen.dart';
import 'features/buyer/presentation/screens/product_details.dart';
import 'features/chat/presentation/screens/chat_page.dart';
import 'features/fisher/logic/orders_bloc/orders_bloc.dart';
import 'features/fisher/presentation/screens/catch_details.dart';
import 'features/fisher/presentation/screens/congratulations_screen.dart';
import 'features/fisher/presentation/screens/market_trends.dart';
import 'features/fisher/presentation/screens/notifications_screen.dart';
import 'features/fisher/presentation/screens/offer_details.dart';
import 'features/fisher/presentation/screens/order_details.dart';
import 'features/user/logic/user_bloc/user_bloc.dart';
import 'features/user/presentation/screens/account_info/personal_information.dart';
import 'features/user/presentation/screens/account_info/reviews.dart';
import 'features/user/presentation/screens/observation_info.dart';
import 'features/user/presentation/screens/role_selection_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  // Now listens to the state of the UserBloc
  GoRouterRefreshStream(Stream<UserState> stream) {
    // We only need to notify listeners when the role changes from/to 'unknown'
    // or when the user is successfully loaded.
    _subscription = stream.listen((state) {
      if (state is UserLoaded || state is UserError) {
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<UserState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// -------------------------------------------------------------------------
// 2. Updated Router Creation Function
// -------------------------------------------------------------------------

// Accepts the new UserBloc instead of the old RoleCubit
GoRouter createRouter(UserBloc userBloc) {
  return GoRouter(
    initialLocation: '/',
    // Use the UserBloc stream for refresh listening
    refreshListenable: GoRouterRefreshStream(userBloc.stream),

    redirect: (context, state) {
      final userState = userBloc.state;
      final bool isRoot = state.fullPath == '/';

      // Handle the loading state by waiting
      if (userState is UserLoading) {
        return isRoot
            ? null
            : '/'; // Allow staying on root, redirect others to root
      }

      // Get the determined role from the loaded state
      final Role currentRole = userState is UserLoaded
          ? userState.role
          : Role.unknown;

      // ---------------------------------------------------------------------
      // 🎯 FIX: Modify Rule 2 to allow the root path access.
      // ---------------------------------------------------------------------

      // Rule 1: Not loaded/Unknown role attempts to access non-root path -> Redirect to root
      if (currentRole == Role.unknown && !isRoot) {
        return '/';
      }

      // Rule 2 (MODIFIED): A valid role loaded attempts to access the root path (`/`).
      // We explicitly allow the user to stay on the root path (the RoleScreen).
      if (currentRole != Role.unknown && isRoot) {
        // Return null to allow the current path (which is '/')
        return null;
      }

      // Rule 3: Allow navigation for all other cases (e.g., Fisher access /fisher/home)
      return null;
    },

    // ---------------------------------------------------------------------
    // 3. Route Definitions (unchanged, as they are URL-based)
    // ---------------------------------------------------------------------
    routes: [
      GoRoute(path: '/', builder: (_, __) => const RoleScreen()),
      GoRoute(
        path: '/fisher',
        builder: (_, __) => BlocProvider(
          create: (context) => sl<OrdersBloc>(),
          child: const Fisher(),
        ),
        routes: [
          GoRoute(
            path: 'catch-details/:id',
            builder: (context, state) {
              final catchId = state.pathParameters['id']!;
              return CatchDetails(catchId: catchId);
            },
          ),
          GoRoute(
            path: 'order-details/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return BlocProvider(
                create: (context) => sl<OrdersBloc>(),
                child: OrderDetails(orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: 'offer-details/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return BlocProvider(
                create: (context) => sl<OffersBloc>(),
                child: FisherOfferDetails(offerId: offerId),
              );
            },
          ),
          GoRoute(
            path: 'congratulations/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return CongratulationsScreen(offerId: offerId);
            },
          ),
          GoRoute(
            path: 'market-trends',
            builder: (_, __) => const MarketTrends(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(path: 'chat', builder: (_, __) => const ChatPage()),
        ],
      ),
      GoRoute(
        path: '/buyer',
        builder: (_, __) =>
            BlocProvider(create: (context) => sl<OffersBloc>(), child: Buyer()),

        routes: [
          GoRoute(
            path: 'product-details/:id',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetails(productId: productId);
            },
          ),
          GoRoute(
            path: 'offer-details/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return BlocProvider(
                create: (context) => sl<OffersBloc>(),
                child: BuyerOfferDetails(offerId: offerId),
              );
            },
          ),
          GoRoute(
            path: 'order-details/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return BuyerOrderDetails(orderId: orderId);
            },
          ),
          GoRoute(path: 'orders', builder: (_, __) => const BuyerOrders()),
          GoRoute(
            path: 'congratulations/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return BuyerCongratulationsScreen(offerId: offerId);
            },
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const BuyerNotificationsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/user-profile/:role',
        builder: (context, state) {
          final role = state.pathParameters['role']!;
          return BlocProvider(
            create: (context) => sl<UserBloc>(),
            child: UserProfile(role: role),
          );
        },
        routes: [
          GoRoute(
            path: 'account-info',
            builder: (context, state) {
              return AccountInfo(role: state.pathParameters['role']!);
            },
            routes: [
              GoRoute(
                path: "personal-information",
                builder: (context, state) => const PersonalInformation(),
              ),
              GoRoute(
                path: "reviews",
                builder: (context, state) => const Reviews(),
              ),
            ],
          ),
          GoRoute(
            path: 'observation-info',
            builder: (context, state) {
              return const ObservationInfo();
            },
          ),
          GoRoute(path: 'projects', builder: (context, state) => Projects()),
          GoRoute(path: 'beaches', builder: (context, state) => Beaches()),
          GoRoute(path: 'about', builder: (context, state) => About()),
          GoRoute(path: 'logout', builder: (context, state) => Logout()),
        ],
      ),
    ],
  );
}
