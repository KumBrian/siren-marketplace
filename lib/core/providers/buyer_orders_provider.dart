import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/order_filter_providers.dart';
import 'package:siren_marketplace/core/types/enum.dart' hide OfferStatus;
import 'package:siren_marketplace/features/buyer/presentation/models/display_item.dart';

/// Provider that merges buyer offers and orders into a list of DisplayItems
/// and applies filters and sorting.
final filteredBuyerItemsProvider = Provider<AsyncValue<List<DisplayItem>>>((
  ref,
) {
  final offersAsync = ref.watch(buyerOffersProvider);
  final ordersAsync = ref.watch(buyerOrdersWithProductProvider);
  final filter = ref.watch(ordersFilterProvider);

  if (offersAsync.isLoading || ordersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (offersAsync.hasError) {
    return AsyncValue.error(offersAsync.error!, offersAsync.stackTrace!);
  }
  if (ordersAsync.hasError) {
    return AsyncValue.error(ordersAsync.error!, ordersAsync.stackTrace!);
  }

  final offers = offersAsync.value ?? [];
  final orders = ordersAsync.value ?? [];
  final List<DisplayItem> allItems = [];

  // Add Orders
  for (final order in orders) {
    allItems.add(DisplayItem.fromOrder(order));
  }

  // Add Offers (exclude those that are already orders or completed)
  for (final offer in offers) {
    final hasOrder = orders.any((o) => o.offerId == offer.id);
    if (!hasOrder &&
        !offer.isAccepted &&
        !offer.isFinal &&
        offer.status != OfferStatus.completed) {
      allItems.add(DisplayItem.fromOffer(offer));
    }
  }

  // Apply Filters
  var filtered = allItems;

  // Status Filter
  if (filter.selectedStatuses.isNotEmpty) {
    filtered = filtered
        .where((item) => filter.selectedStatuses.contains(item.status))
        .toList();
  }

  // Search Filter (if needed, though not explicitly requested in filter modal, but SearchBar exists)
  if (filter.searchQuery.isNotEmpty) {
    // Search by ID or maybe catch name (would need catch data)
    // For now, let's search by ID
    filtered = filtered
        .where((item) => item.id.contains(filter.searchQuery))
        .toList();
  }

  // Sorting
  filtered.sort((a, b) {
    if (filter.sortBy == SortBy.newOld) {
      return b.dateCreated.compareTo(a.dateCreated);
    } else if (filter.sortBy == SortBy.oldNew) {
      return a.dateCreated.compareTo(b.dateCreated);
    }
    return 0;
  });

  return AsyncValue.data(filtered);
});
