import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/offers_filter_cubit/offers_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
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
  List<Offer> _applyOffersFilteringAndSorting(
    List<Offer> offers,
    OffersFilterState state,
  ) {
    List<Offer> filteredList = offers;

    final selectedStatuses = state.activeStatuses
        .map((statusName) {
          try {
            return OfferStatus.values.firstWhere(
              (s) => s.name == statusName.toLowerCase(),
            );
          } catch (e) {
            return OfferStatus.unknown;
          }
        })
        .where((s) => s != OfferStatus.unknown)
        .toSet();

    if (selectedStatuses.isNotEmpty) {
      filteredList = filteredList.where((offer) {
        return selectedStatuses.contains(offer.status);
      }).toList();
    }

    // --- Sorting by Date (createdAt) ---
    filteredList.sort((a, b) {
      if (state.activeSortBy == SortBy.newOld) {
        // Newest to Oldest (Descending)
        return b.dateCreated.compareTo(a.dateCreated);
      } else if (state.activeSortBy == SortBy.oldNew) {
        // Oldest to Newest (Ascending)
        return a.dateCreated.compareTo(b.dateCreated);
      }
      // No sorting/default order
      return 0;
    });

    // 💡 NOTE: Implement search/searchQuery logic here if you add it to the cubit state.

    return filteredList;
  }

  void _showFilterModal(BuildContext context, List<Offer> allOffers) {
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
                  children: OfferStatus.values
                      .where((s) => s != OfferStatus.unknown)
                      .map((status) {
                        final title =
                            status.name.substring(0, 1).toUpperCase() +
                            status.name.substring(1);
                        return FilterButton(
                          title: title,
                          color: AppColors.getStatusColor(status),
                          isSelected: filteredState.pendingStatuses.contains(
                            title,
                          ),
                          onPressed: () => filterCubit.toggleStatus(title),
                        );
                      })
                      .toList(),
                ),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        filterCubit.clearAllFilters();
                        context.read<BuyerCubit>().loadBuyerData(
                          buyerId: CURRENT_BUYER_ID,
                        );
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

  void _showSortModal(BuildContext context, List<Offer> allOffers) {
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
                        context.read<BuyerCubit>().loadBuyerData(
                          buyerId: CURRENT_BUYER_ID,
                        );
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

  //
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

  Widget _buildSearchAndFilterRow(BuildContext context, List<Offer> allOffers) {
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
                      onTap: () => _showSortModal(context, allOffers),
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
                  width: double.infinity, // locks full width of Expanded
                  child: Material(
                    color: AppColors.white100,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      splashColor: AppColors.blue700.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showFilterModal(context, allOffers),
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
      body: BlocBuilder<BuyerCubit, BuyerState>(
        builder: (context, buyerState) {
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
          final loadedState = buyerState as BuyerLoaded;
          final allOffers = loadedState.madeOffers;

          // 2. Nested BlocBuilder for applying filters
          return BlocBuilder<OffersFilterCubit, OffersFilterState>(
            builder: (context, filterState) {
              final filteredOffers = _applyOffersFilteringAndSorting(
                allOffers,
                filterState,
              );

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
                      SizedBox(
                        height: 56,
                        child: _buildSearchAndFilterRow(
                          context,
                          filteredOffers,
                        ),
                      ),

                      const SizedBox(height: 8), // Added standard spacing

                      Expanded(
                        child: filteredOffers.isEmpty
                            ? const Center(
                                child: Text(
                                  "No orders found matching your criteria.",
                                  style: TextStyle(color: AppColors.textGray),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: filteredOffers.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOffers[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: OrderCard(
                                      offer: order,
                                      onPressed: () {
                                        order.status == OfferStatus.pending ||
                                                order.status ==
                                                    OfferStatus.rejected
                                            ? context.go(
                                                "/buyer/offer-details/${order.id}",
                                              )
                                            : context.go(
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
