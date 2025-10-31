import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/order_bloc/order_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/for_sale_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/sold_card.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart';

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
      final ordersBloc = context.read<OrdersBloc>();
      final catchesBloc = context.read<CatchesBloc>();

      // 🔒 Only fetch if not already loaded
      if (ordersBloc.state is OrdersInitial) {
        ordersBloc.add(LoadAllFisherOrders(userId: fisherId));
      }
      if (catchesBloc.state is! CatchesLoaded) {
        catchesBloc.add(LoadCatchesByFisher(fisherId: fisherId));
      }
    }
  }

  double _calculateTurnover(List<Order> orders) {
    return orders
        .where((order) => order.offer.status == OfferStatus.completed)
        .fold<double>(0, (sum, order) => sum + order.offer.price);
  }

  int _totalOffersWithUpdates(List<Catch> allCatches) {
    int total = 0;
    for (final c in allCatches) {
      total += c.offers.where((o) => o.hasUpdateForFisher).length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) => prev != curr && curr is UserLoaded,
      listener: (context, userState) {
        if (userState is UserLoaded && userState.role == Role.fisher) {
          final fisherId = userState.user!.id;

          final ordersBloc = context.read<OrdersBloc>();
          final catchesBloc = context.read<CatchesBloc>();

          final alreadyLoadedOrders = ordersBloc.state is OrdersLoaded;
          final alreadyLoadedCatches = catchesBloc.state is CatchesLoaded;

          if (!alreadyLoadedCatches) {
            catchesBloc.add(LoadCatchesByFisher(fisherId: fisherId));
          }
          if (!alreadyLoadedOrders) {
            ordersBloc.add(LoadAllFisherOrders(userId: fisherId));
          }
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
            BlocBuilder<CatchesBloc, CatchesState>(
              builder: (context, cState) {
                if (cState is! CatchesLoaded) return const SizedBox.shrink();
                final allCatches = cState.catches;
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

            return BlocBuilder<CatchesBloc, CatchesState>(
              builder: (context, catchesState) {
                if (catchesState is CatchesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catchesState is CatchesLoaded) {
                  final allCatches = catchesState.catches;

                  final forSaleCatches = allCatches
                      .where((c) => c.status == CatchStatus.available)
                      .where(
                        (c) =>
                            c.availableWeight > 0 ||
                            c.offers.any(
                              (o) => o.status == OfferStatus.pending,
                            ),
                      )
                      .toList();

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
                                      BlocBuilder<OrdersBloc, OrdersState>(
                                        builder: (context, orderState) {
                                          if (orderState is OrdersLoaded) {
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
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          // For Sale
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
                                                    const Text(
                                                      "Your shop is empty for now.",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Add your first item to start selling.",
                                                      style: TextStyle(
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
                                          // Sold
                                          BlocBuilder<OrdersBloc, OrdersState>(
                                            builder: (context, orderState) {
                                              if (orderState is OrdersLoading) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (orderState is OrdersError) {
                                                return Center(
                                                  child: Text(
                                                    "Error loading sales data: ${orderState.message}",
                                                  ),
                                                );
                                              }
                                              if (orderState is OrdersLoaded) {
                                                final completedOrders = orderState
                                                    .orders
                                                    .where(
                                                      (o) =>
                                                          o.offer.status ==
                                                              OfferStatus
                                                                  .accepted ||
                                                          o.offer.status ==
                                                              OfferStatus
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
                                                      const SizedBox(height: 8),
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
                                                    final catchImageUrl =
                                                        order
                                                            .catchModel
                                                            .images
                                                            .isNotEmpty
                                                        ? order
                                                              .catchModel
                                                              .images
                                                              .first
                                                        : "";
                                                    final catchTitle =
                                                        order.catchModel.name;

                                                    return SoldCard(
                                                      offer: order.offer,
                                                      catchImageUrl:
                                                          catchImageUrl,
                                                      catchTitle: catchTitle,
                                                      onPressed: () => context.push(
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
                      Positioned(
                        bottom: 24,
                        right: 0,
                        left: 0,
                        child: CustomNavBar(role: Role.fisher),
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
}
