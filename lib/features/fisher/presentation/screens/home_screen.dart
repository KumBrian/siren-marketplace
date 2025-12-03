import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';

import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';

class FisherHome extends ConsumerWidget {
  const FisherHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final catchesAsync = ref.watch(fisherCatchesProvider);
    final offersAsync = ref.watch(fisherOffersProvider);
    final ordersAsync = ref.watch(fisherOrdersProvider);
    final turnover = ref.watch(fisherTurnoverProvider);
    final pendingOffersCount = ref.watch(fisherPendingOffersCountProvider);

    return Scaffold(
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
          userAsync.when(
            data: (user) {
              if (user == null) {
                return IconButton(
                  onPressed: () {},
                  icon: Icon(
                    CustomIcons.notificationbell,
                    color: AppColors.textBlue,
                  ),
                );
              }

              return IconButton(
                onPressed: () => context.go("/fisher/notifications"),
                icon: pendingOffersCount > 0
                    ? Badge(
                        label: Text("$pendingOffersCount"),
                        child: Icon(
                          CustomIcons.notificationbell,
                          color: AppColors.textBlue,
                        ),
                      )
                    : Icon(
                        CustomIcons.notificationbell,
                        color: AppColors.textBlue,
                      ),
              );
            },
            loading: () => IconButton(
              onPressed: () {},
              icon: Icon(
                CustomIcons.notificationbell,
                color: AppColors.textBlue,
              ),
            ),
            error: (_, __) => IconButton(
              onPressed: () {},
              icon: Icon(
                CustomIcons.notificationbell,
                color: AppColors.textBlue,
              ),
            ),
          ),
        ],
      ),
      body: catchesAsync.when(
        data: (catches) {
          return offersAsync.when(
            data: (offers) {
              // Filter for sale catches - those that are available
              final forSaleCatches = catches
                  .where((c) => c.status == CatchStatus.available)
                  .where((c) => c.availableWeight.kilograms > 0)
                  .toList();

              // Check which catches have unviewed offers
              final catchesWithUnviewedOffers = <String>{};
              for (final offer in offers) {
                if (offer.hasUpdateForFisher) {
                  catchesWithUnviewedOffers.add(offer.catchId);
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Turnover Card
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
                                formatPrice(turnover),
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
                    // Tabs
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
                                  // For Sale Tab
                                  _buildForSaleTab(
                                    forSaleCatches,
                                    catchesWithUnviewedOffers,
                                    context,
                                  ),
                                  // Sold Tab
                                  _buildSoldTab(
                                    ordersAsync,
                                    catches,
                                    offers,
                                    context,
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text("Error loading offers: $error")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text("Error loading catches: $error")),
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
    );
  }

  Widget _buildForSaleTab(
    List<Catch> forSaleCatches,
    Set<String> catchesWithUnviewedOffers,
    BuildContext context,
  ) {
    // Sort catches by date posted descending (effectively by expiry date descending)
    // "7 days all the way down to expired"
    final sortedCatches = List<Catch>.from(forSaleCatches)
      ..sort((a, b) => b.datePosted.compareTo(a.datePosted));

    if (sortedCatches.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Image.asset("assets/images/no-offers.png"),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your shop is empty for now.",
            style: TextStyle(
              color: AppColors.textBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text(
            "Add your first item to start selling.",
            style: TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: sortedCatches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = sortedCatches[index];
        final hasUnviewedOffer = catchesWithUnviewedOffers.contains(item.id);

        return ForSaleCard(
          catchData: item,
          hasPendingOffers: hasUnviewedOffer,
          onPressed: () => context.go('/fisher/catch-details/${item.id}'),
        );
      },
    );
  }

  Widget _buildSoldTab(
    AsyncValue<List<Order>> ordersAsync,
    List<Catch> allCatches,
    List<Offer> offers,
    BuildContext context,
  ) {
    return ordersAsync.when(
      data: (List<Order> orders) {
        final completedOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.accepted ||
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.cancelled,
            )
            .toList();

        // Sort orders: Accepted -> Completed -> Cancelled
        completedOrders.sort((a, b) {
          final statusPriority = {
            OrderStatus.accepted: 0,
            OrderStatus.completed: 1,
            OrderStatus.cancelled: 2,
          };

          final priorityA = statusPriority[a.status] ?? 99;
          final priorityB = statusPriority[b.status] ?? 99;

          if (priorityA != priorityB) {
            return priorityA.compareTo(priorityB);
          }

          // Secondary sort by date updated (newest first)
          return b.dateUpdated.compareTo(a.dateUpdated);
        });

        if (completedOrders.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset("assets/images/no-offers.png"),
              ),
              const SizedBox(height: 8),
              const Text(
                "No sales recorded yet.",
                style: TextStyle(
                  color: AppColors.textBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                "Complete an accepted offer to see your turnover.",
                style: TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: completedOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = completedOrders[index];

            // Find the corresponding catch (with safe fallback)
            Catch catchItem;
            try {
              catchItem = allCatches.firstWhere((c) => c.id == order.catchId);
            } catch (_) {
              // If catch not found, skip this order
              if (allCatches.isEmpty) return const SizedBox.shrink();
              catchItem = allCatches.first;
            }

            // Find the corresponding offer (with safe fallback)
            Offer offer;
            try {
              offer = offers.firstWhere((o) => o.id == order.offerId);
            } catch (_) {
              // If offer not found, skip this order
              if (offers.isEmpty) return const SizedBox.shrink();
              offer = offers.first;
            }

            final catchImageUrl = catchItem.images.isNotEmpty
                ? catchItem.images.first
                : "";
            final catchTitle = catchItem.species.name;

            return SoldCard(
              offer: offer,
              catchImageUrl: catchImageUrl,
              catchTitle: catchTitle,
              orderStatus: order.status,
              onPressed: () =>
                  context.push("/fisher/order-details/${order.id}"),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text("Error loading sales data: $error")),
    );
  }
}
