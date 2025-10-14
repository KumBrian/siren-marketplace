// lib/screens/fisher/fisher_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart';

class FisherHome extends StatelessWidget {
  const FisherHome({super.key});

  // Helper method to calculate turnover
  double _calculateTurnover(List<Catch> soldCatches) {
    // ... (logic remains the same)
    return soldCatches.fold<double>(
      0,
      (sum, c) =>
          sum +
          c.offers
              .where(
                (o) =>
                    o.status == OfferStatus.accepted ||
                    o.status == OfferStatus.completed,
              )
              .fold(0, (s, o) => s + o.price),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // 🆕 1. Use BlocListener to trigger the CatchesBloc once the User is loaded.
    return BlocListener<UserBloc, UserState>(
      // Listen only to transitions that result in a successful load of a Fisher user.
      listener: (context, userState) {
        if (userState is UserLoaded && userState.role == Role.fisher) {
          // Dispatch the LoadCatchesByFisher event with the Fisher's ID
          context.read<CatchesBloc>().add(
            LoadCatchesByFisher(fisherId: userState.user!.id),
          );

          // NOTE: You must also implement LoadCatchesByFisher in your CatchesBloc:
          // on<LoadCatchesByFisher>((event, emit) async {
          //   // ... use catchRepository.getCatchMapsByFisherId(event.fisherId)
          // });
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
            height: 50,
          ),
          actions: [
            IconButton(
              onPressed: () => context.go("/fisher/notifications"),
              icon: const Badge(
                label: Text("3"),
                child: Icon(
                  Icons.notifications_none,
                  color: AppColors.textBlue,
                ),
              ),
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

                  // --- Filtering Logic (Remains the same) ---
                  final forSaleCatches = allCatches
                      .where(
                        (c) =>
                            c.availableWeight > 0 ||
                            c.offers.any(
                              (o) => o.status == OfferStatus.pending,
                            ),
                      )
                      .toList();

                  final soldCatches = allCatches
                      .where(
                        (c) =>
                            (c.offers.isNotEmpty) &&
                            c.offers.any(
                              (o) =>
                                  o.status == OfferStatus.accepted ||
                                  o.status == OfferStatus.completed,
                            ),
                      )
                      .toList();

                  final turnover = _calculateTurnover(soldCatches);
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
                                        "${turnover.toInt()} CFA",
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
                                          // For Sale List
                                          forSaleCatches.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    "You have no catches listed for sale.",
                                                  ),
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

                                          // Sold List
                                          soldCatches.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    "No catches have been sold yet.",
                                                  ),
                                                )
                                              : ListView.separated(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 80,
                                                        top: 16,
                                                      ),
                                                  itemCount: soldCatches.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                  itemBuilder: (context, index) {
                                                    final item =
                                                        soldCatches[index];

                                                    // Safely get the first accepted/completed offer
                                                    final acceptedOffer = item
                                                        .offers
                                                        .firstWhere(
                                                          (o) =>
                                                              o.status ==
                                                                  OfferStatus
                                                                      .accepted ||
                                                              o.status ==
                                                                  OfferStatus
                                                                      .completed,
                                                        );

                                                    final catchImageUrl =
                                                        item.images.isNotEmpty
                                                        ? item.images.first
                                                        : "";
                                                    final catchTitle =
                                                        item.name;

                                                    return SoldCard(
                                                      offer: acceptedOffer,
                                                      catchImageUrl:
                                                          catchImageUrl,
                                                      catchTitle: catchTitle,
                                                      onPressed: () => context.go(
                                                        "/fisher/order-details/${acceptedOffer.id}",
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
