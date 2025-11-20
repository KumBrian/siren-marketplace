import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';

part 'filtered_products_state.dart';

class FilteredProductsCubit extends Cubit<FilteredProductsState> {
  final CatchRepository _catchRepository;
  final ProductsFilterCubit _filterCubit;
  late final StreamSubscription _filterSubscription;

  FilteredProductsCubit({
    required CatchRepository catchRepository,
    required ProductsFilterCubit filterCubit,
  }) : _catchRepository = catchRepository,
       _filterCubit = filterCubit,
       super(const FilteredProductsState()) {
    // Apply filters only when "Apply" is pressed
    _filterSubscription = _filterCubit.stream.listen((filterState) {
      if (filterState.applyFilters) {
        _applyFiltersAndSort();
      }
    });

    loadProducts();
  }

  Future<void> loadProducts() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final catches = await _catchRepository.fetchMarketCatches();

      final uniqueSpecies = catches.map((c) => c.species).toSet().toList();
      final uniqueLocations = catches.map((c) => c.market).toSet().toList();

      emit(
        state.copyWith(
          allCatches: catches,
          displayedCatches: catches,
          uniqueSpecies: uniqueSpecies,
          uniqueLocations: uniqueLocations,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load products: $e',
        ),
      );
    }
  }

  void _applyFiltersAndSort() {
    final filterState = _filterCubit.state;
    List<Catch> filteredList = List.from(state.allCatches);

    // Filter by species
    if (filterState.selectedSpecies.isNotEmpty) {
      final ids = filterState.selectedSpecies.map((s) => s.id).toSet();
      filteredList = filteredList
          .where((c) => ids.contains(c.species.id))
          .toList();
    }

    // Filter by location
    if (filterState.selectedLocations.isNotEmpty) {
      final locs = filterState.selectedLocations.toSet();
      filteredList = filteredList
          .where((c) => locs.contains(c.market))
          .toList();
    }

    // Filter by min weight
    if (filterState.minWeight > 0) {
      // 🔑 CRITICAL FIX: Convert filter input (assumed to be in Kg) to Grams
      final minWeightInGrams = filterState.minWeight * 1000;

      filteredList = filteredList
          .where((c) => c.availableWeight >= minWeightInGrams)
          .toList();
    }

    // Apply both sorts (composite)
    filteredList = _sortCatches(filteredList, filterState);

    emit(state.copyWith(displayedCatches: filteredList));
  }

  List<Catch> _sortCatches(List<Catch> list, ProductsFilterState filterState) {
    int comparator(Catch a, Catch b) {
      // 1) Sort by price first (if selected)
      if (filterState.sortByPrice != SortBy.none) {
        final priceA = a.pricePerKg;
        final priceB = b.pricePerKg;
        final priceCompare = priceA.compareTo(priceB);
        final priceResult = filterState.sortByPrice == SortBy.highLow
            ? -priceCompare
            : priceCompare;
        if (priceResult != 0) return priceResult;
      }

      // 2) Sort by date (if selected)
      if (filterState.sortByDate != SortBy.none) {
        final dateA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
        final dateCompare = dateA.compareTo(dateB);
        final dateResult = filterState.sortByDate == SortBy.newOld
            ? -dateCompare
            : dateCompare;
        if (dateResult != 0) return dateResult;
      }

      // Default fallback: newest first
      final fallbackA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
      final fallbackB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
      return fallbackB.compareTo(fallbackA);
    }

    list.sort(comparator);
    return list;
  }

  void setAllCatches(List<Catch> catches) {
    emit(state.copyWith(allCatches: catches, displayedCatches: catches));
  }

  @override
  Future<void> close() {
    _filterSubscription.cancel();
    return super.close();
  }
}
