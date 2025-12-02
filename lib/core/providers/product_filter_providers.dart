import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/types/enum.dart';

/// Filter state for products
class ProductsFilter {
  final List<Species> selectedSpecies;
  final List<String> selectedLocations;
  final int minWeightGrams;
  final SortBy sortByDate;
  final SortBy sortByPrice;
  final String searchQuery;

  const ProductsFilter({
    this.selectedSpecies = const [],
    this.selectedLocations = const [],
    this.minWeightGrams = 0,
    this.sortByDate = SortBy.none,
    this.sortByPrice = SortBy.none,
    this.searchQuery = '',
  });

  ProductsFilter copyWith({
    List<Species>? selectedSpecies,
    List<String>? selectedLocations,
    int? minWeightGrams,
    SortBy? sortByDate,
    SortBy? sortByPrice,
    String? searchQuery,
  }) {
    return ProductsFilter(
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      minWeightGrams: minWeightGrams ?? this.minWeightGrams,
      sortByDate: sortByDate ?? this.sortByDate,
      sortByPrice: sortByPrice ?? this.sortByPrice,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  int get totalFilters {
    int count = 0;
    if (selectedSpecies.isNotEmpty) count++;
    if (selectedLocations.isNotEmpty) count++;
    if (minWeightGrams > 0) count++;
    return count;
  }

  void clear() {
    // This method is kept for API compatibility but state is immutable
    // Use the provider's update method instead
  }
}

/// Provider for product filter state
final productsFilterProvider = StateProvider<ProductsFilter>((ref) {
  return const ProductsFilter();
});

/// Provider for filtered and sorted catches
final filteredCatchesProvider = Provider<AsyncValue<List<Catch>>>((ref) {
  final catchesAsync = ref.watch(availableCatchesProvider);
  final filter = ref.watch(productsFilterProvider);

  return catchesAsync.when(
    data: (catches) {
      var filtered = catches;

      // Apply species filter
      if (filter.selectedSpecies.isNotEmpty) {
        filtered = filtered.where((c) {
          return filter.selectedSpecies.any((s) => s.id == c.species.id);
        }).toList();
      }

      // Apply location filter
      if (filter.selectedLocations.isNotEmpty) {
        filtered = filtered.where((c) {
          return filter.selectedLocations.contains(c.market);
        }).toList();
      }

      // Apply min weight filter
      if (filter.minWeightGrams > 0) {
        filtered = filtered.where((c) {
          return c.availableWeight.grams >= filter.minWeightGrams;
        }).toList();
      }

      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        filtered = filtered.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.species.name.toLowerCase().contains(query) ||
              c.market.toLowerCase().contains(query);
        }).toList();
      }

      // Apply date sorting
      if (filter.sortByDate != SortBy.none) {
        filtered.sort((a, b) {
          return filter.sortByDate == SortBy.newOld
              ? b.datePosted.compareTo(a.datePosted)
              : a.datePosted.compareTo(b.datePosted);
        });
      }

      // Apply price sorting
      if (filter.sortByPrice != SortBy.none) {
        filtered.sort((a, b) {
          return filter.sortByPrice == SortBy.highLow
              ? b.pricePerKg.amountPerKg.compareTo(a.pricePerKg.amountPerKg)
              : a.pricePerKg.amountPerKg.compareTo(b.pricePerKg.amountPerKg);
        });
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Provider for unique species (for filter dropdown)
final uniqueSpeciesProvider = Provider<List<Species>>((ref) {
  final catchesAsync = ref.watch(availableCatchesProvider);
  return catchesAsync.when(
    data: (catches) {
      final speciesMap = <String, Species>{};
      for (var c in catches) {
        speciesMap[c.species.id] = c.species;
      }
      return speciesMap.values.toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for unique locations (for filter dropdown)
final uniqueLocationsProvider = Provider<List<String>>((ref) {
  final catchesAsync = ref.watch(availableCatchesProvider);
  return catchesAsync.when(
    data: (catches) {
      return catches.map((c) => c.market).toSet().toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
