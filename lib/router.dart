import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/screens/buyer/buyer.dart';
import 'package:siren_marketplace/screens/buyer/buyer_congratulations_screen.dart';
import 'package:siren_marketplace/screens/buyer/buyer_notifications_screen.dart';
import 'package:siren_marketplace/screens/buyer/buyer_offer_details.dart';
import 'package:siren_marketplace/screens/buyer/buyer_order_details.dart';
import 'package:siren_marketplace/screens/buyer/buyer_orders.dart';
import 'package:siren_marketplace/screens/buyer/product_details.dart';
import 'package:siren_marketplace/screens/fisher/catch_details.dart';
import 'package:siren_marketplace/screens/fisher/congratulations_screen.dart';
import 'package:siren_marketplace/screens/fisher/fisher_home.dart';
import 'package:siren_marketplace/screens/fisher/fisher_offer_details.dart';
import 'package:siren_marketplace/screens/fisher/market_trends.dart';
import 'package:siren_marketplace/screens/fisher/notifications_screen.dart';
import 'package:siren_marketplace/screens/fisher/order_details.dart';
import 'package:siren_marketplace/screens/role_screen.dart';

import 'bloc/cubits/role_cubit.dart';
import 'constants/types.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final roleCubit = BlocProvider.of<RoleCubit>(context, listen: false);
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
    GoRoute(path: '/', builder: (context, state) => const RoleScreen()),
    GoRoute(
      path: '/fisher',
      builder: (context, state) => const FisherHome(),
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
            return OrderDetails(orderId: orderId);
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
        GoRoute(path: 'market-trends', builder: (_, _) => const MarketTrends()),
        GoRoute(
          path: 'notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/buyer',
      builder: (_, _) => const Buyer(),
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
        GoRoute(
          path: 'orders',
          builder: (context, state) => const BuyerOrders(),
        ),
        GoRoute(
          path: 'congratulations/:id',
          builder: (context, state) {
            final offerId = state.pathParameters['id']!;
            return BuyerCongratulationsScreen(offerId: offerId);
          },
        ),
        GoRoute(
          path: 'notifications',
          builder: (_, _) => const BuyerNotificationsScreen(),
        ),
      ],
    ),
  ],
);
