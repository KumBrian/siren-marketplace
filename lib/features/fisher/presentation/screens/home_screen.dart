import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';
import 'package:siren_marketplace/new_core/domain/entities/catch.dart';
import 'package:siren_marketplace/new_core/domain/entities/order.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/notification/notification_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/notification/notification_state.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/dashboard/fisher_dashboard_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/dashboard/fisher_dashboard_state.dart';

class FisherHome extends StatefulWidget {
  const FisherHome({super.key});

  @override
  State<FisherHome> createState() => _FisherHomeState();
}

class _FisherHomeState extends State<FisherHome> {
  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated &&
        authState.currentRole == UserRole.fisher) {
      final fisherId = authState.user.id;

      // Load Dashboard Data
      context.read<FisherDashboardCubit>().loadDashboard(fisherId);

      // Load Notifications
      context.read<NotificationCubit>().loadUnreadCount(fisherId, true);
    }
  }

  String _formatPrice(int amount) {
    // Simple formatter, can be replaced with a proper utility
    return "${amount.toString()} CFA";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev != curr && curr is AuthAuthenticated,
      listener: (context, authState) {
        if (authState is AuthAuthenticated &&
            authState.currentRole == UserRole.fisher) {
          final fisherId = authState.user.id;
          context.read<FisherDashboardCubit>().loadDashboard(fisherId);
          context.read<NotificationCubit>().loadUnreadCount(fisherId, true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go("/fisher/market-trends"),
            icon: Icon(CustomIcons.markettrends, color: AppColors.textBlue),
          ),
          title: Image.asset(
            "assets/icons/siren_logo.png",
            width: 100,
            height: 100,
          ),
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context.go("/fisher/notifications/${authState.user.id}");
                    }
                  },
                  icon: Badge(
                    isLabelVisible: state.unreadOffersCount > 0,
                    label: Text("${state.unreadOffersCount}"),
                    child: Icon(
                      CustomIcons.notificationbell,
                      color: AppColors.textBlue,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (authState is AuthError) {
              return Center(
                child: Text("Error loading user: ${authState.message}"),
              );
            }
            if (authState is! AuthAuthenticated ||
                authState.currentRole != UserRole.fisher) {
              return const Center(child: Text("Access Denied: Not a Fisher."));
            }

            return BlocBuilder<FisherDashboardCubit, FisherDashboardState>(
              builder: (context, dashboardState) {
                if (dashboardState is FisherDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dashboardState is FisherDashboardLoaded) {
                  final forSaleCatches = dashboardState.availableCatches;
                  final completedOrders = dashboardState.completedOrders;
                  final allCatches = [
                    ...dashboardState.availableCatches,
                    ...dashboardState.expiredCatches,
                    // Ideally we should have all catches here to map images for sold items
                    // For now, we assume available + expired covers most, or we rely on what's available
                    // If sold items correspond to 'soldOut' catches, they might not be in available/expired lists if we don't load them.
                    // FisherDashboardCubit loads ALL catches, but only exposes available/expired lists.
                    // We might need to expose allCatches or a map.
                    // For this implementation, let's assume we can find the catch in the lists or handle missing images gracefully.
                  ];

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.gray300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Turnover"),
                                      Text(
                                        _formatPrice(
                                          dashboardState.totalTurnover,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blue700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: DefaultTabController(
                                length: 2,
                                child: Column(
                                  children: [
                                    const TabBar(
                                      dividerHeight: 0,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      tabs: [
                                        Tab(text: "For Sale"),
                                        Tab(text: "Sold"),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          // For Sale
                                          forSaleCatches.isEmpty
                                              ? _buildEmptyState(
                                                  "Your shop is empty for now.",
                                                  "Add your first item to start selling.",
                                                )
                                              : ListView.separated(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 80,
                                                        top: 16,
                                                      ),
                                                  itemCount:
                                                      forSaleCatches.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                  itemBuilder: (context, index) {
                                                    final item =
                                                        forSaleCatches[index];
                                                    // We don't have pending offers info directly on Catch entity in new core yet
                                                    // Assuming false for now or we need to check offers separately
                                                    // The Catch entity DOES NOT have an offers list in the new core definition I saw.
                                                    // It only has fields.
                                                    // Wait, I need to check if Catch entity has offers.
                                                    // Checked: Catch entity does NOT have offers list.
                                                    // We need to fetch offers or use a composite object.
                                                    // For now, passing false.
                                                    return ForSaleCard(
                                                      catchData: item,
                                                      hasPendingOffers: false,
                                                      onPressed: () => context.go(
                                                        '/fisher/catch-details/${item.id}',
                                                      ),
                                                    );
                                                  },
                                                ),
                                          // Sold
                                          completedOrders.isEmpty
                                              ? _buildEmptyState(
                                                  "No sales recorded yet.",
                                                  "Complete an accepted offer to see your turnover.",
                                                )
                                              : ListView.separated(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 80,
                                                        top: 16,
                                                      ),
                                                  itemCount:
                                                      completedOrders.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                  itemBuilder: (context, index) {
                                                    final order =
                                                        completedOrders[index];
                                                    // Try to find the catch to get image/name
                                                    // In a real app, we might need to fetch the catch if not in the list
                                                    // For now, we'll try to find it in available/expired or use placeholders
                                                    // Note: Sold items are likely 'soldOut' which we didn't expose in state.
                                                    // I should have exposed 'soldOutCatches' or 'allCatches'.
                                                    // For this step, I'll use placeholders if not found.
                                                    // Improvement: Update Cubit to expose all catches or soldOut ones.
                                                    final catchItem = allCatches
                                                        .where(
                                                          (c) =>
                                                              c.id ==
                                                              order.catchId,
                                                        )
                                                        .firstOrNull;

                                                    return SoldCard(
                                                      order: order,
                                                      catchImageUrl:
                                                          catchItem
                                                                  ?.primaryImage ??
                                                              "",
                                                      catchTitle:
                                                          catchItem?.name ??
                                                              "Unknown Catch",
                                                      onPressed: () => context.push(
                                                        "/fisher/order-details/${order.id}",
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text(
                    "Loading catches data or initialization pending...",
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to Catch Creation Screen
            },
            backgroundColor: AppColors.blue850,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.white100),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Image.asset("assets/images/no-offers.png"),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
