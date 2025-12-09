import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/features/buyer/presentation/screens/buyer.dart';

import 'package:siren_marketplace/features/buyer/presentation/screens/order_details.dart';
import 'package:siren_marketplace/features/buyer/presentation/screens/orders_screen.dart';
import 'package:siren_marketplace/features/buyer/presentation/screens/product_details.dart';
import 'package:siren_marketplace/features/chat/presentation/screens/chat_page.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/add_catch.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/catch_details.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/catch_report_screen.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/fisher.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/market_trends.dart';
import 'package:siren_marketplace/features/shared/presentation/screens/shared_notifications_screen.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/order_details.dart';
import 'package:siren_marketplace/features/shared/presentation/screens/offer_details_screen.dart';
import 'package:siren_marketplace/features/shared/presentation/screens/shared_review_screen.dart';
import 'package:siren_marketplace/features/user/presentation/screens/about.dart';
import 'package:siren_marketplace/features/user/presentation/screens/account_info.dart';
import 'package:siren_marketplace/features/user/presentation/screens/account_info/personal_information.dart';
import 'package:siren_marketplace/features/user/presentation/screens/beaches.dart';
import 'package:siren_marketplace/features/user/presentation/screens/logout.dart';
import 'package:siren_marketplace/features/user/presentation/screens/observation_info.dart';
import 'package:siren_marketplace/features/user/presentation/screens/projects.dart';
import 'package:siren_marketplace/features/user/presentation/screens/role_selection_screen.dart';
import 'package:siren_marketplace/features/user/presentation/screens/user_profile.dart';

/// A notifier that listens to the [currentUserProvider] and notifies listeners
/// when the user state changes. This is used by GoRouter to refresh its state.
class AuthNotifier extends ChangeNotifier {
  final Ref ref;

  AuthNotifier(this.ref) {
    ref.listen(currentUserProvider, (previous, next) {
      print(
        'AuthNotifier: currentUserProvider changed from ${previous?.value?.id} to ${next.value?.id}',
      );
      notifyListeners();
    });
  }
}

final authNotifierProvider = Provider<AuthNotifier>((ref) {
  return AuthNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    // Refresh the router when the user provider changes
    refreshListenable: authNotifier,
    redirect: (context, state) {
      print('GoRouter: redirect called. Path: ${state.fullPath}');
      // READ the current state, do NOT watch it here to avoid recreating the router
      final userAsync = ref.read(currentUserProvider);
      final bool isRoot = state.fullPath == '/';

      print('GoRouter: userAsync state: $userAsync');

      // Handle loading state
      // Only redirect to splash/root if we are loading AND have no data.
      // If we have data (e.g. background refresh), let the user proceed/stay.
      if (userAsync.isLoading && !userAsync.hasValue) {
        print('GoRouter: User is loading and has no value. isRoot: $isRoot');
        return isRoot ? null : '/';
      }

      final user = userAsync.value;
      final currentRole = user?.currentRole ?? UserRole.unknown;
      print('GoRouter: User loaded. Role: $currentRole');

      // Rule 1: Not loaded/Unknown role attempts to access non-root path -> Redirect to root
      if (currentRole == UserRole.unknown && !isRoot) {
        print('GoRouter: Unknown role on non-root path. Redirecting to /');
        return '/';
      }

      // Rule 2: A valid role loaded attempts to access the root path (`/`).
      // We explicitly allow the user to stay on the root path (the RoleScreen).
      if (currentRole != UserRole.unknown && isRoot) {
        print(
          'GoRouter: Valid role on root path. Staying on / (RoleScreen handles navigation)',
        );
        return null;
      }

      // Rule 3: Allow navigation for all other cases
      print('GoRouter: Allowing navigation to ${state.fullPath}');
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const RoleScreen()),
      GoRoute(
        path: '/fisher',
        builder: (_, __) => const Fisher(),
        routes: [
          GoRoute(
            path: 'catch-details/:id',
            builder: (context, state) {
              final catchId = state.pathParameters['id']!;
              return CatchDetails(catchId: catchId);
            },
          ),
          GoRoute(
            path: 'catch-report/:id',
            builder: (context, state) {
              final catchId = state.pathParameters['id']!;
              return CatchReportScreen(catchId: catchId);
            },
          ),
          GoRoute(
            path: 'add-catch',
            builder: (context, state) {
              return const AddCatchScreen();
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
              return SharedOfferDetailsScreen(offerId: offerId);
            },
          ),
          GoRoute(
            path: 'market-trends',
            builder: (_, __) => const MarketTrends(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const SharedNotificationsScreen(),
          ),
          GoRoute(
            path: 'chat/:conversationId',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return ChatPage(conversationId: conversationId);
            },
          ),
          GoRoute(
            path: "reviews/:userId",
            builder: (context, state) {
              final String? userId = state.pathParameters['userId'];

              if (userId == null) {
                return const Scaffold(
                  body: Center(child: Text("Invalid User ID")),
                );
              }

              return SharedReviewScreen(userId: userId);
            },
          ),
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
              return SharedOfferDetailsScreen(offerId: offerId);
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
            path: 'notifications',
            builder: (_, __) => const SharedNotificationsScreen(),
          ),
          GoRoute(
            path: 'chat/:conversationId',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return ChatPage(conversationId: conversationId);
            },
          ),
          GoRoute(
            path: "reviews/:userId",
            builder: (context, state) {
              final String? userId = state.pathParameters['userId'];

              if (userId == null) {
                return const Scaffold(
                  body: Center(child: Text("Invalid User ID")),
                );
              }

              return SharedReviewScreen(userId: userId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/user-profile/:role',
        builder: (context, state) {
          final role = state.pathParameters['role']!;
          return UserProfile(role: role);
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
                path: "reviews/:userId",
                builder: (context, state) {
                  final String? userId = state.pathParameters['userId'];

                  if (userId == null) {
                    return const Scaffold(
                      body: Center(child: Text("Invalid User ID")),
                    );
                  }

                  return SharedReviewScreen(userId: userId);
                },
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
});
