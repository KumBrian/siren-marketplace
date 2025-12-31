import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/providers/buyer_orders_provider.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/order_filter_providers.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/types/enum.dart' hide OfferStatus;
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/presentation/models/display_item.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/order_card.dart';

class BuyerOrders extends ConsumerStatefulWidget {
  const BuyerOrders({super.key});

  @override
  ConsumerState<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends ConsumerState<BuyerOrders> {
  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredBuyerItemsProvider);
    final notificationCount = ref.watch(buyerNotificationCountProvider);

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
            icon: Badge(
              label: Text("$notificationCount"),
              isLabelVisible: notificationCount > 0,
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.textBlue,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Column(
            spacing: 16,
            children: [
              const SectionHeader("Offers", fontSize: 16),
              Container(color: AppColors.textBlue, height: 2.0),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both offers and orders
          ref.invalidate(buyerOffersProvider);
          ref.invalidate(buyerOrdersWithProductProvider);
          // Wait for them to reload
          await Future.wait([
            ref.read(buyerOffersProvider.future),
            ref.read(buyerOrdersWithProductProvider.future),
          ]);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 56, child: _buildSearchAndFilterRow(context)),
              const SizedBox(height: 8),
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading orders: $error',
                      style: const TextStyle(color: AppColors.fail500),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          "No orders found matching your criteria.",
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _OrderListItem(item: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            onChanged: (value) {
              ref
                  .read(ordersFilterProvider.notifier)
                  .update((state) => state.copyWith(searchQuery: value));
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Consumer(
            builder: (context, ref, child) {
              final filterState = ref.watch(ordersFilterProvider);
              final hasFilters = filterState.sortBy != SortBy.newOld;

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
                      child: const Padding(
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
          child: Consumer(
            builder: (context, ref, child) {
              final filterState = ref.watch(ordersFilterProvider);
              final hasFilters = filterState.selectedStatuses.isNotEmpty;

              return Badge(
                isLabelVisible: hasFilters,
                label: Text("${filterState.selectedStatuses.length}"),
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

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _FilterModalContent(),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _SortModalContent(),
    );
  }
}

class _OrderListItem extends ConsumerWidget {
  final DisplayItem item;

  const _OrderListItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we have embedded product data, use it directly!
    if (item.product != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: OrderCard(
          product: item.product,
          status: item.status,
          weight: item.weight,
          price: item.price,
          hasUpdate: item.hasUpdate,
          onPressed: () => _handlePressed(context),
        ),
      );
    }

    // Fallback to fetching catch if product data is missing
    final catchAsync = ref.watch(catchProvider(item.catchId));

    return catchAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (catchItem) {
        if (catchItem == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: OrderCard(
            catchItem: catchItem,
            status: item.status,
            weight: item.weight,
            price: item.price,
            hasUpdate: item.hasUpdate,
            onPressed: () => _handlePressed(context),
          ),
        );
      },
    );
  }

  void _handlePressed(BuildContext context) {
    if (item.isOrder) {
      // Always navigate to order details for orders (accepted, completed, cancelled)
      context.push("/buyer/order-details/${item.id}");
    } else {
      // Navigate to Offer Details for offers (pending, rejected, counter-offers)
      context.push("/buyer/offer-details/${item.id}");
    }
  }
}

class _FilterModalContent extends ConsumerStatefulWidget {
  const _FilterModalContent();

  @override
  ConsumerState<_FilterModalContent> createState() =>
      _FilterModalContentState();
}

class _FilterModalContentState extends ConsumerState<_FilterModalContent> {
  late List<OfferStatus> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = List.from(
      ref.read(ordersFilterProvider).selectedStatuses,
    );
  }

  void _toggleStatus(OfferStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                isSelected: _selectedStatuses.contains(status),
                onPressed: () => _toggleStatus(status),
              );
            }).toList(),
          ),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatuses = [];
                  });
                  ref
                      .read(ordersFilterProvider.notifier)
                      .update((state) => state.copyWith(selectedStatuses: []));
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset All",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              CustomButton(
                title: "Apply Filters",
                onPressed: () {
                  ref
                      .read(ordersFilterProvider.notifier)
                      .update(
                        (state) =>
                            state.copyWith(selectedStatuses: _selectedStatuses),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortModalContent extends ConsumerStatefulWidget {
  const _SortModalContent();

  @override
  ConsumerState<_SortModalContent> createState() => _SortModalContentState();
}

class _SortModalContentState extends ConsumerState<_SortModalContent> {
  late SortBy _sortBy;

  @override
  void initState() {
    super.initState();
    _sortBy = ref.read(ordersFilterProvider).sortBy;
  }

  @override
  Widget build(BuildContext context) {
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
          _buildDateSortOptions(),
          const Divider(thickness: 2, color: AppColors.gray200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(ordersFilterProvider.notifier)
                      .update((state) => state.copyWith(sortBy: SortBy.newOld));
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset All",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              CustomButton(
                title: "Apply",
                onPressed: () {
                  ref
                      .read(ordersFilterProvider.notifier)
                      .update((state) => state.copyWith(sortBy: _sortBy));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSortOptions() {
    return Column(
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortBy,
          title: const Text('Oldest to Newest', style: TextStyle(fontSize: 14)),
          value: SortBy.oldNew,
          onChanged: (v) {
            if (v != null) setState(() => _sortBy = v);
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortBy,
          title: const Text('Newest to Oldest', style: TextStyle(fontSize: 14)),
          value: SortBy.newOld,
          onChanged: (v) {
            if (v != null) setState(() => _sortBy = v);
          },
        ),
      ],
    );
  }
}
