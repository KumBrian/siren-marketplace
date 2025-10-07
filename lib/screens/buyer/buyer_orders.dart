import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_state.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/order_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/order_data.dart';

class BuyerOrders extends StatefulWidget {
  const BuyerOrders({super.key});

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  final orders = sampleOrders;

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
            icon: Icon(Icons.notifications_none, color: AppColors.textBlue),
          ),
        ],
        bottom: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 36,
          backgroundColor: AppColors.white100,

          title: Text(
            "Orders",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: AppColors.textBlue,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          spacing: 8,
          children: [
            Divider(color: AppColors.textBlue, height: 2, thickness: 2),
            Expanded(flex: 1, child: OrdersFilter()),
            Expanded(
              flex: 12,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  spacing: 8,
                  children: orders
                      .map(
                        (order) => OrderCard(
                          order: order,
                          onPressed: () {
                            context.go("/buyer/order-details/${order.orderId}");
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersFilter extends StatelessWidget {
  const OrdersFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: SearchBar(
            hintText: "Search...",
            scrollPadding: EdgeInsets.symmetric(vertical: 4),
            textStyle: WidgetStateProperty.all(
              TextStyle(fontSize: 16, color: AppColors.textBlue),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.white100),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(16),
              ),
            ),

            trailing: [Icon(Icons.search, color: AppColors.textBlue)],
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        Expanded(
          flex: 1,
          child: Material(
            color: AppColors.white100,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              splashColor: AppColors.blue700.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return BlocBuilder<OrdersFilterCubit, OrdersFilterState>(
                      builder: (context, state) {
                        final cubit = context.read<OrdersFilterCubit>();

                        return Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 32,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              const Text(
                                "Filter by:",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Text("Status"),
                              Text(
                                "Select all that apply",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGray,
                                ),
                              ),
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
                                    child: Text(
                                      "Reset All",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  CustomButton(
                                    title: "Apply Filters",
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.filter_alt_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
