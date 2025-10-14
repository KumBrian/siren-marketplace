import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/order_card.dart';

// 💡 FIX: Define the current buyer ID, consistent with the ID that places orders in seeder.dart.
const String CURRENT_BUYER_ID = 'buyer_id_1';

class BuyerOrders extends StatefulWidget {
  const BuyerOrders({super.key});

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  // Function to apply filtering logic (No change, as it's correct for Order/Offer status)
  List<Order> _applyFilters(List<Order> orders, OrdersFilterState state) {
    if (state.selectedStatuses.isEmpty) {
      return orders;
    }

    // Filter by Status
    return orders.where((order) {
      final status = order.offer.status;
      return state.selectedStatuses.contains(status);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white100,
        actions: [
          IconButton(
            onPressed: () {
              context.go("/buyer/notifications");
            },
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textBlue,
            ),
          ),
        ],
        bottom: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 36,
          backgroundColor: AppColors.white100,
          title: const Text(
            "Orders",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: AppColors.textBlue,
            ),
          ),
        ),
      ),
      // 1. Listen to the BuyerCubit and its new state
      body: BlocBuilder<BuyerCubit, BuyerState>(
        builder: (context, buyerState) {
          // 🆕 Handle Loading and Error States
          if (buyerState is BuyerLoading || buyerState is BuyerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (buyerState is BuyerError) {
            return Center(
              child: Text(
                'Error loading orders: ${buyerState.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.fail500),
              ),
            );
          }

          // 🆕 Extract orders from the loaded state
          final loadedState = buyerState as BuyerLoaded;
          final allOrders = loadedState.orders;

          // 2. Nested BlocBuilder for applying filters
          return BlocBuilder<OrdersFilterCubit, OrdersFilterState>(
            builder: (context, filterState) {
              final filteredOrders = _applyFilters(allOrders, filterState);

              return RefreshIndicator(
                // 💡 FIX: Pass the required buyerId to the loadBuyerData call
                onRefresh: () => context.read<BuyerCubit>().loadBuyerData(
                  buyerId: CURRENT_BUYER_ID,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        color: AppColors.textBlue,
                        height: 2,
                        thickness: 2,
                      ),

                      // Filter widget is a fixed height row, so we just wrap it
                      SizedBox(
                        height: 56, // adjust to match your design
                        child: const OrdersFilter(),
                      ),
                      const SizedBox(height: 8), // Added standard spacing

                      Expanded(
                        child: filteredOrders.isEmpty
                            ? const Center(
                                child: Text(
                                  "No orders found matching your criteria.",
                                  style: TextStyle(color: AppColors.textGray),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: OrderCard(
                                      order: order,
                                      onPressed: () {
                                        // ⚠️ Assuming Order model has an `id` or `orderId` property
                                        context.go(
                                          "/buyer/order-details/${order.id}",
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrdersFilter extends StatelessWidget {
  const OrdersFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersFilterCubit, OrdersFilterState>(
      builder: (context, state) {
        final cubit = context.read<OrdersFilterCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: SearchBar(
                hintText: "Search...",
                scrollPadding: const EdgeInsets.symmetric(vertical: 4),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 16, color: AppColors.textBlue),
                ),
                backgroundColor: WidgetStateProperty.all(AppColors.white100),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                trailing: const [Icon(Icons.search, color: AppColors.textBlue)],
                elevation: WidgetStateProperty.all(0),
              ),
            ),
            const SizedBox(width: 16), // Added standard spacing
            Expanded(
              flex: 1,
              child: Material(
                color: AppColors.white100,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  splashColor: AppColors.blue700.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 32,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Filter by:",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text("Status"),
                              const SizedBox(height: 12),
                              const Text(
                                "Select all that apply",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilterButton(
                                    title: "Pending",
                                    color: AppColors.getStatusColor(
                                      OfferStatus.pending,
                                    ),
                                    isSelected: state.selectedStatuses.contains(
                                      OfferStatus.pending,
                                    ),
                                    onPressed: () =>
                                        cubit.toggleStatus(OfferStatus.pending),
                                  ),
                                  FilterButton(
                                    title: "Accepted",
                                    color: AppColors.getStatusColor(
                                      OfferStatus.accepted,
                                    ),
                                    isSelected: state.selectedStatuses.contains(
                                      OfferStatus.accepted,
                                    ),
                                    onPressed: () => cubit.toggleStatus(
                                      OfferStatus.accepted,
                                    ),
                                  ),
                                  FilterButton(
                                    title: "Completed",
                                    color: AppColors.getStatusColor(
                                      OfferStatus.completed,
                                    ),
                                    isSelected: state.selectedStatuses.contains(
                                      OfferStatus.completed,
                                    ),
                                    onPressed: () => cubit.toggleStatus(
                                      OfferStatus.completed,
                                    ),
                                  ),
                                  FilterButton(
                                    title: "Rejected",
                                    color: AppColors.getStatusColor(
                                      OfferStatus.rejected,
                                    ),
                                    isSelected: state.selectedStatuses.contains(
                                      OfferStatus.rejected,
                                    ),
                                    onPressed: () => cubit.toggleStatus(
                                      OfferStatus.rejected,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      cubit.clear();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Reset All",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  CustomButton(
                                    title: "Apply Filters",
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.filter_alt_outlined),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
