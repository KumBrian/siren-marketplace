import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'core/types/enum.dart';
import 'features/buyer/presentation/screens/buyer.dart';
import 'features/buyer/presentation/screens/congratulations_screen.dart';
import 'features/buyer/presentation/screens/notifications_screen.dart';
import 'features/buyer/presentation/screens/offer_details.dart';
import 'features/buyer/presentation/screens/order_details.dart';
import 'features/buyer/presentation/screens/orders_screen.dart';
import 'features/buyer/presentation/screens/product_details.dart';
import 'features/chat/presentation/screens/chat_page.dart';
import 'features/fisher/presentation/screens/catch_details.dart';
import 'features/fisher/presentation/screens/congratulations_screen.dart';
import 'features/fisher/presentation/screens/home_screen.dart';
import 'features/fisher/presentation/screens/market_trends.dart';
import 'features/fisher/presentation/screens/notifications_screen.dart';
import 'features/fisher/presentation/screens/offer_details.dart';
import 'features/fisher/presentation/screens/order_details.dart';
import 'features/user/logic/bloc/user_bloc.dart';
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
        builder: (_, __) => const FisherHome(),
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
              final offerId = state.pathParameters['id']!;
              return OrderDetails(offerId: offerId);
            },
          ),
          GoRoute(
            path: 'offer-details/:id',
            builder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return FisherOfferDetails(offerId: offerId);
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
        builder: (_, __) => const Buyer(),
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
              return BuyerOfferDetails(offerId: offerId);
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
    ],
  );
}
