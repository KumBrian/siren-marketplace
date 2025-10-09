import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/components/custom_nav_bar.dart';
import 'package:siren_marketplace/components/for_sale_card.dart';
import 'package:siren_marketplace/components/sold_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class FisherHome extends StatefulWidget {
  const FisherHome({super.key});

  @override
  State<FisherHome> createState() => _FisherHomeState();
}

class _FisherHomeState extends State<FisherHome> {
  @override
  void initState() {
    super.initState();
    // Load fisher data if not loaded yet
    context.read<FisherCubit>().loadFisher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Badge(
              label: Text("3"),
              child: Icon(Icons.notifications_none, color: AppColors.textBlue),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FisherCubit, Fisher?>(
        builder: (context, fisher) {
          if (fisher == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final forSaleCatches = fisher.catches
              .where(
                (c) => c.offers.any((o) => o.status == OfferStatus.pending),
              )
              .toList();

          final soldCatches = fisher.catches
              .where(
                (c) => c.offers.any(
                  (o) =>
                      o.status == OfferStatus.accepted ||
                      o.status == OfferStatus.completed,
                ),
              )
              .toList();

          final turnover = soldCatches.fold<double>(
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

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
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
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                        top: 16,
                                      ),
                                      child: Column(
                                        spacing: 8,
                                        children: forSaleCatches.map((item) {
                                          return ForSaleCard(
                                            catchData: item,
                                            onPressed: () => context.go(
                                              '/fisher/catch-details/${item.catchId}',
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    // Sold
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                        top: 16,
                                      ),
                                      child: Column(
                                        spacing: 8,
                                        children: soldCatches.map((item) {
                                          final offer = item.offers.firstWhere(
                                            (o) =>
                                                o.status ==
                                                    OfferStatus.accepted ||
                                                o.status ==
                                                    OfferStatus.completed,
                                          );

                                          debugPrint(offer.status.name);

                                          return SoldCard(
                                            offer: offer,
                                            onPressed: () => context.go(
                                              "/fisher/order-details/${offer.offerId}",
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.blue850,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: AppColors.white100),
        ),
      ),
    );
  }
}
