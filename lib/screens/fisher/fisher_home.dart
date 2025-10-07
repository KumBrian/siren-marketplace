import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_nav_bar.dart';
import 'package:siren_marketplace/components/for_sale_card.dart';
import 'package:siren_marketplace/components/sold_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class FisherHome extends StatefulWidget {
  const FisherHome({super.key});

  @override
  State<FisherHome> createState() => _FisherHomeState();
}

class _FisherHomeState extends State<FisherHome> {
  final List<Catch> catches = sampleCatches;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go("/fisher/market-trends");
          },
          icon: Icon(Icons.bar_chart, color: AppColors.textBlue),
        ),
        title: Image.asset(
          "assets/icons/siren_logo.png",
          width: 100,
          height: 50,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go("/fisher/notifications");
            },
            icon: Badge(
              label: Text("3"),
              child: Icon(Icons.notifications_none, color: AppColors.textBlue),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Turnover"),
                          Text(
                            "40,000 CFA",
                            style: TextStyle(
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
                                // For Sale Tab
                                SingleChildScrollView(
                                  padding: const EdgeInsets.only(
                                    bottom: 80,
                                    top: 16,
                                  ),
                                  child: Column(
                                    spacing: 16,
                                    children: catches.map((item) {
                                      return ForSaleCard(
                                        catchData: item,
                                        onPressed: () {
                                          context.go(
                                            '/fisher/catch-details/${item.catchId}',
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // Sold Tab
                                SingleChildScrollView(
                                  padding: const EdgeInsets.only(
                                    bottom: 80,
                                    top: 16,
                                  ),
                                  child: Column(
                                    spacing: 16,
                                    children: catches.map((item) {
                                      return SoldCard(
                                        catchData: item,
                                        onPressed: () {
                                          context.go(
                                            "/fisher/order-details/${item.offers[0].offerId}",
                                          );
                                        },
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.blue850,
          shape: CircleBorder(),
          child: Icon(Icons.add, color: AppColors.white100),
        ),
      ),
    );
  }
}
