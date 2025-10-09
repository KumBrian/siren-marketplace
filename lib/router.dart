import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/screens/buyer/buyer_congratulations_screen.dart';
import 'package:siren_marketplace/screens/buyer/buyer_notifications_screen.dart';
import 'package:siren_marketplace/screens/buyer/buyer_offer_details.dart';
import 'package:siren_marketplace/screens/buyer/buyer_order_details.dart';
import 'package:siren_marketplace/screens/buyer/buyer_orders.dart';
import 'package:siren_marketplace/screens/buyer/product_details.dart';
import 'package:siren_marketplace/screens/fisher/catch_details.dart';
import 'package:siren_marketplace/screens/fisher/chat_page.dart';
import 'package:siren_marketplace/screens/fisher/congratulations_screen.dart';
import 'package:siren_marketplace/screens/fisher/fisher_home.dart';
import 'package:siren_marketplace/screens/fisher/fisher_offer_details.dart';
import 'package:siren_marketplace/screens/fisher/market_trends.dart';
import 'package:siren_marketplace/screens/fisher/notifications_screen.dart';
import 'package:siren_marketplace/screens/fisher/order_details.dart';
import 'package:siren_marketplace/screens/role_screen.dart';

import 'bloc/cubits/role_cubit.dart';
import 'constants/types.dart' hide Buyer;
import 'screens/buyer/buyer.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(UserRoleCubit roleCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(roleCubit.stream),
    redirect: (context, state) {
      final role = roleCubit.state;

      if (role == Role.unknown && state.fullPath != '/') {
        return '/';
      }
      if (role != Role.unknown && state.fullPath == '/') {
        return role == Role.fisher ? '/fisher' : '/buyer';
      }

      return null;
    },
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
