import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/types/enum.dart' hide OfferStatus;
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/order_card.dart';
import 'package:siren_marketplace/features/fisher/logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/orders_bloc/orders_cubit.dart';

// Helper class to unify Offer and Order for display
class DisplayItem {
  final String id;
  final String catchId;
  final OfferStatus status;
  final DateTime dateCreated;
  final double weight;
  final int price;
  final bool hasUpdate;
  final bool isOrder;

  DisplayItem({
    required this.id,
    required this.catchId,
    required this.status,
    required this.dateCreated,
    required this.weight,
    required this.price,
    required this.hasUpdate,
    required this.isOrder,
  });

  factory DisplayItem.fromOffer(Offer offer) {
    return DisplayItem(
      id: offer.id,
      catchId: offer.catchId,
      status: offer.status,
      dateCreated: offer.dateCreated,
      weight: offer.currentTerms.weight.kilograms,
      price: offer.currentTerms.totalPrice.amount,
      hasUpdate: offer.hasUpdateForBuyer,
      isOrder: false,
    );
  }

  factory DisplayItem.fromOrder(Order order) {
    // Map OrderStatus to OfferStatus for display consistency if needed,
    // or use status.name directly. Here we map to OfferStatus for simplicity in UI.
    OfferStatus mappedStatus;
    switch (order.status) {
      case OrderStatus.active:
        mappedStatus = OfferStatus.accepted;
        break;
      case OrderStatus.completed:
        mappedStatus = OfferStatus.completed;
        break;
      case OrderStatus.cancelled:
        mappedStatus = OfferStatus.rejected;
        break;
    }

    return DisplayItem(
      id: order.id,
      catchId: order.catchId,
      status: mappedStatus,
      dateCreated: order.dateCreated,
      weight: (order.terms.weight.grams as num).toDouble(),
      price: order.terms.totalPrice.amount,
      hasUpdate:
          false, // Orders might have updates (reviews), but for now false
      isOrder: true,
    );
  }
}

class BuyerOrders extends StatefulWidget {
  const BuyerOrders({super.key});

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sessionService = context.read<SessionService>();
    final user = await sessionService.getCurrentUser();
    if (user != null && mounted) {
      context.read<OffersCubit>().loadForBuyer(user.id);
      context.read<OrdersCubit>().loadForUser(user.id);
    }
  }

  List<DisplayItem> _applyFilteringAndSorting(
    List<DisplayItem> items,
    OffersFilterState state,
  ) {
    List<DisplayItem> filteredList = items;

    final selectedStatuses = state.activeStatuses
        .map((statusName) {
          try {
            return OfferStatus.values.firstWhere(
              (s) => s.name == statusName.toLowerCase(),
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<OfferStatus>()
        .toSet();

    if (selectedStatuses.isNotEmpty) {
      filteredList = filteredList.where((item) {
        return selectedStatuses.contains(item.status);
      }).toList();
    }

    // --- Sorting by Date (createdAt) ---
    filteredList.sort((a, b) {
      if (state.activeSortBy == SortBy.newOld) {
        return b.dateCreated.compareTo(a.dateCreated);
      } else if (state.activeSortBy == SortBy.oldNew) {
        return a.dateCreated.compareTo(b.dateCreated);
      }
      return 0;
    });

    return filteredList;
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<OffersFilterCubit, OffersFilterState>(
        builder: (context, filterState) {
          final filterCubit = context.read<OffersFilterCubit>();
          final filteredState = context.read<OffersFilterCubit>().state;
          final height = MediaQuery.of(context).size.height * 0.35;

          return Container(
            height: height,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const Text(
                  "Filter by:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                const Text("Status", style: TextStyle(fontSize: 12)),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OfferStatus.values.map((status) {
                    final title =
                        status.name.substring(0, 1).toUpperCase() +
                        status.name.substring(1);
                    return FilterButton(
                      title: title,
                      color: AppColors.getStatusColor(status),
                      isSelected: filteredState.pendingStatuses.contains(title),
                      onPressed: () => filterCubit.toggleStatus(title),
                    );
                  }).toList(),
                ),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        filterCubit.clearAllFilters();
                        _loadData();
                        context.pop();
                      },
                      child: const Text(
                        "Reset All",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    CustomButton(
                      title: "Apply Filters",
                      onPressed: () {
                        filterCubit.applyFilters();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<OffersFilterCubit, OffersFilterState>(
        builder: (context, filterState) {
          final filterCubit = context.read<OffersFilterCubit>();
          final height = MediaQuery.of(context).size.height * 0.3;

          return Container(
            height: height,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                const Text(
                  "Sort by:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                _buildDateSortOptions(filterCubit, filterState),
                Divider(thickness: 2, color: AppColors.gray200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        filterCubit.clearAllFilters();
                        _loadData();
                        context.pop();
                      },
                      child: const Text(
                        "Reset All",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    CustomButton(
                      title: "Apply",
                      onPressed: () {
                        filterCubit.applyFilters();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSortOptions(
    OffersFilterCubit cubit,
    OffersFilterState state,
  ) {
    return Column(
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.pendingSortBy,
          title: const Text('Oldest to Newest', style: TextStyle(fontSize: 14)),
          value: SortBy.oldNew,
          onChanged: (v) {
            if (v != null) cubit.setSort(v);
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.pendingSortBy,
          title: const Text('Newest to Oldest', style: TextStyle(fontSize: 14)),
          value: SortBy.newOld,
          onChanged: (v) {
            if (v != null) cubit.setSort(v);
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: SearchBar(
            hintText: "Search...",
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 16, color: AppColors.textBlue),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.white100),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            trailing: const [
              Icon(CustomIcons.search, color: AppColors.textBlue),
            ],
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        Expanded(
          flex: 1,
          child: BlocBuilder<OffersFilterCubit, OffersFilterState>(
            builder: (context, state) {
              final hasFilters = state.activeSortBy != SortBy.none;
              return Badge(
                isLabelVisible: hasFilters,
                alignment: Alignment.topRight,
                largeSize: 3,
                smallSize: 8,
                backgroundColor: AppColors.blue800,
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.white100,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      splashColor: AppColors.blue700.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showSortModal(context),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          CustomIcons.sort,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: BlocBuilder<OffersFilterCubit, OffersFilterState>(
            builder: (context, state) {
              final hasFilters = state.activeStatuses.isNotEmpty;

              return Badge(
                isLabelVisible: hasFilters,
                label: Text("${state.totalFilters}"),
                alignment: Alignment.topRight,
                backgroundColor: AppColors.blue800,
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.white100,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      splashColor: AppColors.blue700.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showFilterModal(context),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          CustomIcons.filter,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Column(
            spacing: 16,
            children: [
              SectionHeader("Offers", fontSize: 16),
              Container(color: AppColors.textBlue, height: 2.0),
            ],
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OffersCubit, OffersState>(
            listener: (context, state) {
              if (state.offers.isNotEmpty) {
                final catchIds = state.offers.map((o) => o.catchId).toList();
                context.read<CatchesCubit>().loadRange(catchIds);
              }
            },
          ),
          BlocListener<OrdersCubit, OrdersState>(
            listener: (context, state) {
              if (state.orders.isNotEmpty) {
                final catchIds = state.orders.map((o) => o.catchId).toList();
                context.read<CatchesCubit>().loadRange(catchIds);
              }
            },
          ),
        ],
        child: BlocBuilder<OffersCubit, OffersState>(
          builder: (context, offersState) {
            return BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, ordersState) {
                if (offersState.loading || ordersState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (offersState.error != null) {
                  return Center(
                    child: Text(
                      'Error loading offers: ${offersState.error}',
                      style: const TextStyle(color: AppColors.fail500),
                    ),
                  );
                }

                // Merge Offers and Orders
                final List<DisplayItem> allItems = [];

                // Add Orders
                for (final order in ordersState.orders) {
                  allItems.add(DisplayItem.fromOrder(order));
                }

                // Add Offers (exclude those that are already orders or completed)
                for (final offer in offersState.offers) {
                  // Check if this offer is already represented by an order
                  final hasOrder = ordersState.orders.any(
                    (o) => o.offerId == offer.id,
                  );
                  // Also exclude if status is accepted/completed as they should be orders
                  // (unless data sync issue, but let's assume orders cover them)
                  if (!hasOrder &&
                      !offer.isAccepted &&
                      !offer.isFinal &&
                      offer.status != OfferStatus.completed) {
                    allItems.add(DisplayItem.fromOffer(offer));
                  }
                }

                return BlocBuilder<OffersFilterCubit, OffersFilterState>(
                  builder: (context, filterState) {
                    final filteredItems = _applyFilteringAndSorting(
                      allItems,
                      filterState,
                    );

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 56,
                              child: _buildSearchAndFilterRow(context),
                            ),

                            const SizedBox(height: 8),

                            Expanded(
                              child: filteredItems.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No orders found matching your criteria.",
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    )
                                  : BlocBuilder<CatchesCubit, CatchesState>(
                                      builder: (context, catchesState) {
                                        return ListView.builder(
                                          padding: const EdgeInsets.only(
                                            bottom: 80,
                                          ),
                                          itemCount: filteredItems.length,
                                          itemBuilder: (context, index) {
                                            final item = filteredItems[index];

                                            // Find catch details
                                            final catchItem = catchesState
                                                .catches
                                                .where(
                                                  (c) => c.id == item.catchId,
                                                )
                                                .firstOrNull;

                                            if (catchItem == null) {
                                              // Loading or error state for this card?
                                              // Or just show placeholder
                                              return const SizedBox.shrink();
                                            }

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
                                              child: OrderCard(
                                                catchItem: catchItem,
                                                status: item.status,
                                                weight: item.weight,
                                                price: item.price,
                                                hasUpdate: item.hasUpdate,
                                                onPressed: () {
                                                  if (item.isOrder) {
                                                    context.go(
                                                      "/buyer/order-details/${item.id}",
                                                    );
                                                  } else {
                                                    context.go(
                                                      "/buyer/offer-details/${item.id}",
                                                    );
                                                  }
                                                },
                                              ),
                                            );
                                          },
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
            );
          },
        ),
      ),
    );
  }
}
