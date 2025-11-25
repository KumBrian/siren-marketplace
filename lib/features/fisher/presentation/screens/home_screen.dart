import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart'
    hide CatchStatus, OfferStatus;
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/features/fisher/new_logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/orders_bloc/orders_cubit.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

// Professional data structure for the list view
class SoldItemData {
  final Catch parentCatch;
  final Offer acceptedOffer;

  SoldItemData({required this.parentCatch, required this.acceptedOffer});
}

class FisherHome extends StatefulWidget {
  const FisherHome({super.key});

  @override
  State<FisherHome> createState() => _FisherHomeState();
}

class _FisherHomeState extends State<FisherHome> {
  @override
  void initState() {
    super.initState();

    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded && userState.role == Role.fisher) {
      final fisherId = userState.user!.id;

      // Load data using new cubits
      context.read<OrdersCubit>().loadForUser(fisherId);
      context.read<CatchesCubit>().loadForFisher(fisherId);
      context.read<OffersCubit>().loadForFisher(fisherId);
    }
  }

  double _calculateTurnover(List<Order> orders) {
    return orders
        .where((order) => order.status == OrderStatus.completed)
        .fold<double>(0, (sum, order) => sum + order.terms.totalPrice.amount);
  }

  int _totalOffersWithUpdates(List<Offer> offers) {
    return offers.where((o) => o.hasUpdateForFisher).length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) => prev != curr && curr is UserLoaded,
      listener: (context, userState) {
        if (userState is UserLoaded && userState.role == Role.fisher) {
          final fisherId = userState.user!.id;

          // Load data using new cubits
          context.read<OrdersCubit>().loadForUser(fisherId);
          context.read<CatchesCubit>().loadForFisher(fisherId);
          context.read<OffersCubit>().loadForFisher(fisherId);
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
            BlocBuilder<OffersCubit, OffersState>(
              builder: (context, offersState) {
                return BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    if (userState is! UserLoaded) {
                      return IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CustomIcons.notificationbell,
                          color: AppColors.textBlue,
                        ),
                      );
                    }

                    final totalUpdates = _totalOffersWithUpdates(
                      offersState.offers,
                    );

                    return IconButton(
                      onPressed: () => context.go(
                        "/fisher/notifications/${userState.user!.id}",
                      ),
                      icon: totalUpdates > 0
                          ? Badge(
                              label: Text("$totalUpdates"),
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
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
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

            return BlocBuilder<CatchesCubit, CatchesState>(
              builder: (context, catchesState) {
                if (catchesState.loading && catchesState.catches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catchesState.error != null &&
                    catchesState.catches.isEmpty) {
                  return Center(
                    child: Text("Error loading catches: ${catchesState.error}"),
                  );
                }

                final allCatches = catchesState.catches;

                return BlocBuilder<OffersCubit, OffersState>(
                  builder: (context, offersState) {
                    // Filter for sale catches - those that are available
                    final forSaleCatches = allCatches
                        .where((c) => c.status == CatchStatus.available)
                        .where((c) => c.availableWeight.kilograms > 0)
                        .toList();

                    // Check which catches have pending offers
                    final catchesWithPendingOffers = <String>{};
                    for (final offer in offersState.offers) {
                      if (offer.status == OfferStatus.pending) {
                        catchesWithPendingOffers.add(offer.catchId);
                      }
                    }

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Turnover"),

                                        BlocBuilder<OrdersCubit, OrdersState>(
                                          builder: (context, orderState) {
                                            if (orderState.orders.isNotEmpty) {
                                              final total = _calculateTurnover(
                                                orderState.orders,
                                              );
                                              return Text(
                                                formatPrice(total),
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.blue700,
                                                ),
                                              );
                                            }
                                            return const Text(
                                              "--",
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.blue700,
                                              ),
                                            );
                                          },
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
                                          physics:
                                              const BouncingScrollPhysics(),
                                          children: [
                                            // For Sale
                                            forSaleCatches.isEmpty
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 120,
                                                        width: 120,
                                                        child: Image.asset(
                                                          "assets/images/no-offers.png",
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        "Your shop is empty for now.",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textBlue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const Text(
                                                        "Add your first item to start selling.",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textGray,
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
                                                      final hasPendingOffer =
                                                          catchesWithPendingOffers
                                                              .contains(
                                                                item.id,
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
                                            // Sold
                                            BlocBuilder<
                                              OrdersCubit,
                                              OrdersState
                                            >(
                                              builder: (context, orderState) {
                                                if (orderState.loading &&
                                                    orderState.orders.isEmpty) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                if (orderState.error != null) {
                                                  return Center(
                                                    child: Text(
                                                      "Error loading sales data: ${orderState.error}",
                                                    ),
                                                  );
                                                }
                                                if (orderState
                                                    .orders
                                                    .isNotEmpty) {
                                                  final completedOrders = orderState
                                                      .orders
                                                      .where(
                                                        (o) =>
                                                            o.status ==
                                                                OrderStatus
                                                                    .active ||
                                                            o.status ==
                                                                OrderStatus
                                                                    .completed,
                                                      )
                                                      .toList();

                                                  if (completedOrders.isEmpty) {
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          height: 120,
                                                          width: 120,
                                                          child: Image.asset(
                                                            "assets/images/no-offers.png",
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        const Text(
                                                          "No sales recorded yet.",
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .textBlue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const Text(
                                                          "Complete an accepted offer to see your turnover.",
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .textGray,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  return ListView.separated(
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

                                                      // Find the corresponding catch
                                                      final catchItem =
                                                          allCatches.firstWhere(
                                                            (c) =>
                                                                c.id ==
                                                                order.catchId,
                                                            orElse: () =>
                                                                allCatches
                                                                    .first,
                                                          );

                                                      // Find the corresponding offer
                                                      final offer = offersState
                                                          .offers
                                                          .firstWhere(
                                                            (o) =>
                                                                o.id ==
                                                                order.offerId,
                                                            orElse: () =>
                                                                offersState
                                                                    .offers
                                                                    .first,
                                                          );

                                                      final catchImageUrl =
                                                          catchItem
                                                              .images
                                                              .isNotEmpty
                                                          ? catchItem
                                                                .images
                                                                .first
                                                          : "";
                                                      final catchTitle =
                                                          catchItem
                                                              .species
                                                              .name;

                                                      return SoldCard(
                                                        offer: offer,
                                                        catchImageUrl:
                                                            catchImageUrl,
                                                        catchTitle: catchTitle,
                                                        onPressed: () =>
                                                            context.push(
                                                              "/fisher/order-details/${order.id}",
                                                            ),
                                                      );
                                                    },
                                                  );
                                                }
                                                return const Center(
                                                  child: Text(
                                                    "Awaiting sales data...",
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
                  },
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
}
