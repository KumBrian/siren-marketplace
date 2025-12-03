import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/types/enum.dart' hide OfferStatus;

class OrdersFilter {
  final List<OfferStatus> selectedStatuses;
  final SortBy sortBy;
  final String searchQuery;

  const OrdersFilter({
    this.selectedStatuses = const [],
    this.sortBy = SortBy.newOld,
    this.searchQuery = '',
  });

  OrdersFilter copyWith({
    List<OfferStatus>? selectedStatuses,
    SortBy? sortBy,
    String? searchQuery,
  }) {
    return OrdersFilter(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  int get totalFilters {
    int count = 0;
    if (selectedStatuses.isNotEmpty) count++;
    if (sortBy != SortBy.newOld)
      count++; // Default sort doesn't count as filter
    return count;
  }
}

final ordersFilterProvider = StateProvider<OrdersFilter>((ref) {
  return const OrdersFilter();
});
