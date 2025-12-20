import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/providers/product_providers.dart';
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
}

/// Provider for product filter state
final productsFilterProvider = StateProvider<ProductsFilter>((ref) {
  return const ProductsFilter();
});

/// Provider for filtered and sorted products
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(availableProductsProvider);
  final filter = ref.watch(productsFilterProvider);

  return productsAsync.when(
    data: (products) {
      var filtered = products;

      // Apply species filter
      if (filter.selectedSpecies.isNotEmpty) {
        filtered = filtered.where((p) {
          return filter.selectedSpecies.any((s) => s.id == p.species.id);
        }).toList();
      }

      // Apply location filter
      if (filter.selectedLocations.isNotEmpty) {
        filtered = filtered.where((p) {
          return filter.selectedLocations.contains(p.marketName);
        }).toList();
      }

      // Apply min weight filter
      if (filter.minWeightGrams > 0) {
        filtered = filtered.where((p) {
          return p.availableWeight.grams >= filter.minWeightGrams;
        }).toList();
      }

      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        filtered = filtered.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.species.name.toLowerCase().contains(query) ||
              p.marketName.toLowerCase().contains(query);
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
  final productsAsync = ref.watch(availableProductsProvider);
  return productsAsync.when(
    data: (products) {
      final speciesMap = <String, Species>{};
      for (var p in products) {
        speciesMap[p.species.id] = p.species;
      }
      return speciesMap.values.toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for unique locations (for filter dropdown)
final uniqueLocationsProvider = Provider<List<String>>((ref) {
  final productsAsync = ref.watch(availableProductsProvider);
  return productsAsync.when(
    data: (products) {
      return products.map((p) => p.marketName).toSet().toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
