import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart'; // Import Offer model
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart';

// Create a professional data structure for the list view
class SoldItemData {
  final Catch parentCatch;
  final Offer acceptedOffer;

  SoldItemData({required this.parentCatch, required this.acceptedOffer});
}

class FisherHome extends StatelessWidget {
  const FisherHome({super.key});

  // Helper method to calculate turnover
  double _calculateTurnover(List<SoldItemData> soldItems) {
    // We now fold over the pre-filtered accepted offers
    return soldItems.fold<double>(
      0,
      (sum, item) => sum + item.acceptedOffer.price,
    );
  }

  // --- New Helper Method: Filter Catches into a flat list of SoldItemData ---
  List<SoldItemData> _getSoldItemData(List<Catch> allCatches) {
    final soldItems = <SoldItemData>[];

    for (final c in allCatches) {
      // Find all offers for this catch that represent a completed sale
      final acceptedOffers = c.offers
          .where(
            (o) =>
                o.status == OfferStatus.accepted ||
                o.status == OfferStatus.completed,
          )
          .toList();

      for (final offer in acceptedOffers) {
        // Create one SoldItemData entry for each successful offer
        soldItems.add(SoldItemData(parentCatch: c, acceptedOffer: offer));
      }
    }
    return soldItems;
  }

  int _totalOffersWithUpdates(List<Catch> allCatches) {
    int total = 0;
    for (final c in allCatches) {
      total += c.offers.where((o) => o.hasUpdateForFisher).length;
    }
    return total;
  }

  // --------------------------------------------------------------------------

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // 1. Use BlocListener to trigger the CatchesBloc once the User is loaded.
    return BlocListener<UserBloc, UserState>(
      // Listen only to transitions that result in a successful load of a Fisher user.
      listener: (context, userState) {
        if (userState is UserLoaded && userState.role == Role.fisher) {
          // Dispatch the LoadCatchesByFisher event with the Fisher's ID
          context.read<CatchesBloc>().add(
            LoadCatchesByFisher(fisherId: userState.user!.id),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go("/fisher/market-trends"),
            icon: Icon(Icons.bar_chart, color: AppColors.textBlue),
          ),
          title: Image.asset(
            "assets/icons/siren_logo.png",
            width: 100,
            height: 100,
          ),
          actions: [
            BlocBuilder<CatchesBloc, CatchesState>(
              builder: (context, cState) {
                if (cState is! CatchesLoaded) return const SizedBox.shrink();
                final allCatches = (cState).catches;
                return IconButton(
                  onPressed: () => context.go("/fisher/notifications"),
                  icon: Badge(
                    label: Text("${_totalOffersWithUpdates(allCatches)}"),
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
        // 2. Wrap the entire body content in the UserBlocBuilder
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            // A. Handle User Loading/Errors (This must be done first)
            if (userState is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userState is UserError) {
              return Center(
                child: Text("Error loading user: ${userState.message}"),
              );
            }
            if (userState is! UserLoaded || userState.role != Role.fisher) {
              return const Center(child: Text("Access Denied: Not a Fisher."));
            }

            // B. Once User is loaded, build the CatchesBloc state
            return BlocBuilder<CatchesBloc, CatchesState>(
              builder: (context, catchesState) {
                if (catchesState is CatchesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catchesState is CatchesLoaded) {
                  final allCatches = catchesState.catches;

                  // --- Filtering Logic (Revised) ---
                  final forSaleCatches = allCatches
                      .where(
                        (c) =>
                            c.availableWeight > 0 ||
                            c.offers.any(
                              (o) => o.status == OfferStatus.pending,
                            ),
                      )
                      .toList();

                  // Get the flattened list of SoldItemData
                  final soldItems = _getSoldItemData(allCatches);

                  // Calculate turnover from the consolidated list
                  final turnover = _calculateTurnover(soldItems);
                  // ------------------------------------------

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            // Turnover Box (Remains the same)
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
                            // Tabs and Lists (Remains the same)
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
                                          // For Sale List (Logic remains the same)
                                          forSaleCatches.isEmpty
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 120,
                                                      width: 120,
                                                      child: Image.asset(
                                                        "assets/images/no-offers.png",
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "Your shop is empty for now.",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Add your first item to start selling.",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textGray,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
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
                                                    final hasPendingOffer = item
                                                        .offers
                                                        .any(
                                                          (o) =>
                                                              o.status ==
                                                              OfferStatus
                                                                  .pending,
                                                        );

                                                    return ForSaleCard(
                                                      catchData: item,
                                                      hasPendingOffers:
                                                          hasPendingOffer,
                                                      onPressed: () => context.go(
                                                        '/fisher/catch-details/${item.id}',
                                                      ),
                                                    );
                                                  },
                                                ),

                                          // Sold List (Revised to use soldItems)
                                          soldItems.isEmpty
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 120,
                                                      width: 120,
                                                      child: Image.asset(
                                                        "assets/images/no-offers.png",
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "No sales recorded yet.",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Complete an accepted offer to see your turnover.",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textGray,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : ListView.separated(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 80,
                                                        top: 16,
                                                      ),
                                                  itemCount: soldItems.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                  itemBuilder: (context, index) {
                                                    final soldData =
                                                        soldItems[index];

                                                    final catchImageUrl =
                                                        soldData
                                                            .parentCatch
                                                            .images
                                                            .isNotEmpty
                                                        ? soldData
                                                              .parentCatch
                                                              .images
                                                              .first
                                                        : "";
                                                    final catchTitle = soldData
                                                        .parentCatch
                                                        .name;

                                                    return SoldCard(
                                                      offer: soldData
                                                          .acceptedOffer,
                                                      // Directly pass the accepted offer
                                                      catchImageUrl:
                                                          catchImageUrl,
                                                      catchTitle: catchTitle,
                                                      onPressed: () => context.go(
                                                        // Navigate using the accepted offer's ID, which maps to the Order ID.
                                                        "/fisher/order-details/${soldData.acceptedOffer.id}",
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
                      // Navigation Bar (Remains the same)
                      Positioned(
                        bottom: 24,
                        right: 0,
                        left: 0,
                        child: CustomNavBar(role: Role.fisher),
                      ),
                    ],
                  );
                }

                // Default state (e.g., CatchesInitial or CatchesError)
                return const Center(
                  child: Text(
                    "Loading catches data or initialization pending...",
                  ),
                );
              },
            );
          },
        ),
        // Floating Action Button (Remains the same)
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
            onPressed: () {
              /* Navigate to Catch Creation Screen */
            },
            backgroundColor: AppColors.blue850,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.white100),
          ),
        ),
      ),
    );
  }
}
