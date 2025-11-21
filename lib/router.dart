// lib/router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// OLD IMPORTS (Keep temporarily)
import 'core/di/injector.dart';
import 'core/types/enum.dart' as OldEnum;
import 'features/buyer/presentation/screens/buyer.dart';
import 'features/buyer/presentation/screens/buyer_review_screen.dart';
import 'features/buyer/presentation/screens/congratulations_screen.dart';
import 'features/buyer/presentation/screens/notifications_screen.dart';
import 'features/buyer/presentation/screens/offer_details.dart';
import 'features/buyer/presentation/screens/order_details.dart';
import 'features/buyer/presentation/screens/orders_screen.dart';
import 'features/buyer/presentation/screens/product_details.dart';
import 'features/chat/presentation/screens/chat_page.dart';
import 'features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'features/fisher/logic/orders_bloc/orders_bloc.dart';
import 'features/fisher/presentation/screens/catch_details.dart';
import 'features/fisher/presentation/screens/congratulations_screen.dart';
import 'features/fisher/presentation/screens/fisher.dart';
import 'features/fisher/presentation/screens/fisher_review_screen.dart';
import 'features/fisher/presentation/screens/market_trends.dart';
import 'features/fisher/presentation/screens/notifications_screen.dart';
import 'features/fisher/presentation/screens/offer_details.dart';
import 'features/fisher/presentation/screens/order_details.dart';
import 'features/user/logic/user_bloc/user_bloc.dart';
import 'features/user/presentation/screens/about.dart';
import 'features/user/presentation/screens/account_info.dart';
import 'features/user/presentation/screens/account_info/personal_information.dart';
import 'features/user/presentation/screens/account_info/reviews.dart';
import 'features/user/presentation/screens/beaches.dart';
import 'features/user/presentation/screens/logout.dart';
import 'features/user/presentation/screens/observation_info.dart';
import 'features/user/presentation/screens/projects.dart';
import 'features/user/presentation/screens/role_selection_screen.dart';
import 'features/user/presentation/screens/user_profile.dart';
import 'new_core/domain/enums/user_role.dart';
// NEW IMPORTS
import 'new_core/presentation/cubits/auth/auth_cubit.dart';
import 'new_core/presentation/cubits/auth/auth_state.dart';

// ============================================================================
// ROUTER REFRESH LISTENER (Hybrid: Listens to both old and new BLoCs)
// ============================================================================

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream({
    required Stream<UserState> oldUserStream,
    required Stream<AuthState> newAuthStream,
  }) {
    // Listen to OLD UserBloc
    _oldSubscription = oldUserStream.listen((state) {
      if (state is UserLoaded || state is UserError) {
        notifyListeners();
      }
    });

    // Listen to NEW AuthCubit
    _newSubscription = newAuthStream.listen((state) {
      if (state is AuthAuthenticated || state is AuthUnauthenticated) {
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<UserState> _oldSubscription;
  late final StreamSubscription<AuthState> _newSubscription;

  @override
  void dispose() {
    _oldSubscription.cancel();
    _newSubscription.cancel();
    super.dispose();
  }
}

// ============================================================================
// ROUTER CREATION (Hybrid: Supports both old and new architecture)
// ============================================================================

GoRouter createRouter(UserBloc userBloc, AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      oldUserStream: userBloc.stream,
      newAuthStream: authCubit.stream,
    ),
    redirect: (context, state) {
      // Get states from both old and new systems
      final oldUserState = userBloc.state;
      final newAuthState = authCubit.state;
      final bool isRoot = state.fullPath == '/';

      // Priority: Use NEW AuthCubit if authenticated, otherwise fall back to OLD
      UserRole? currentRole;

      if (newAuthState is AuthAuthenticated) {
        // NEW system is active
        currentRole = newAuthState.currentRole;
      } else if (oldUserState is UserLoaded) {
        // OLD system is active (map old Role to new UserRole)
        currentRole = _mapOldRoleToNew(oldUserState.role);
      }

      // Handle loading states
      if (oldUserState is UserLoading || newAuthState is AuthLoading) {
        return isRoot ? null : '/';
      }

      // Rule 1: No role and trying to access non-root → redirect to root
      if (currentRole == null && !isRoot) {
        return '/';
      }

      // Rule 2: Has role and on root → allow (can switch roles)
      if (currentRole != null && isRoot) {
        return null;
      }

      // Rule 3: Allow all other navigation
      return null;
    },
    routes: [
      // ======================================================================
      // ROOT ROUTE - Role Selection (Using NEW AuthCubit)
      // ======================================================================
      GoRoute(
        path: '/',
        builder: (_, __) => const RoleScreen(), // Your existing role screen
      ),

      // ======================================================================
      // FISHER ROUTES (Will migrate to new BLoCs progressively)
      // ======================================================================
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
            path: 'notifications/:fisherId',
            builder: (context, state) {
              final String? fisherId = state.pathParameters['fisherId'];
              return NotificationsScreen(fisherId: fisherId!);
            },
          ),
          GoRoute(path: 'chat', builder: (_, __) => const ChatPage()),
          GoRoute(
            path: "reviews/:userId",
            builder: (context, state) {
              final String? userId = state.pathParameters['userId'];
              if (userId == null) {
                return const Scaffold(
                  body: Center(child: Text("Invalid User ID")),
                );
              }
              return FisherReviewScreen(userId: userId);
            },
          ),
        ],
      ),

      // ======================================================================
      // BUYER ROUTES (Will migrate to new BLoCs progressively)
      // ======================================================================
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
          GoRoute(path: 'chat', builder: (_, __) => const ChatPage()),
          GoRoute(
            path: "reviews/:userId",
            builder: (context, state) {
              final String? userId = state.pathParameters['userId'];
              if (userId == null) {
                return const Scaffold(
                  body: Center(child: Text("Invalid User ID")),
                );
              }
              return BuyerReviewScreen(userId: userId);
            },
          ),
        ],
      ),

      // ======================================================================
      // USER PROFILE ROUTES
      // ======================================================================
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
                builder: (context, state) => BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      final userId = state.user?.id;
                      final userName = state.user?.name;
                      return ReviewsScreen(
                        userId: userId!,
                        userName: userName!,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'observation-info',
            builder: (context, state) => const ObservationInfo(),
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

// ============================================================================
// HELPER: Map old Role enum to new UserRole enum
// ============================================================================
UserRole? _mapOldRoleToNew(OldEnum.Role oldRole) {
  switch (oldRole) {
    case OldEnum.Role.fisher:
      return UserRole.fisher;
    case OldEnum.Role.buyer:
      return UserRole.buyer;
    case OldEnum.Role.unknown:
      return null;
  }
}
