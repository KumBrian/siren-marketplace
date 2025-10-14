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
    // Listen for any filter changes and re-apply filters/sort
    _filterSubscription = _filterCubit.stream.listen(
      (_) => _applyFiltersAndSort(),
    );

    // Load initial products
    loadProducts();
  }

  // --------------------------------------------------------------------------
  // Data Loading
  // --------------------------------------------------------------------------
  Future<void> loadProducts() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final catches = await _catchRepository.fetchMarketCatches();

      // Extract unique species and locations for filters
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

      // Apply any active filters/sort
      _applyFiltersAndSort();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load products: $e',
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Filtering & Sorting
  // --------------------------------------------------------------------------
  void _applyFiltersAndSort() {
    List<Catch> filteredList = List.from(state.allCatches);
    final filterState = _filterCubit.state;

    // Apply species filter
    if (filterState.selectedSpecies.isNotEmpty) {
      final selectedIds = filterState.selectedSpecies.map((s) => s.id).toSet();
      filteredList = filteredList
          .where((c) => selectedIds.contains(c.species.id))
          .toList();
    }

    // Apply location filter
    if (filterState.selectedLocations.isNotEmpty) {
      final selectedLocationsSet = filterState.selectedLocations.toSet();
      filteredList = filteredList
          .where((c) => selectedLocationsSet.contains(c.market))
          .toList();
    }

    // Apply sorting
    filteredList = _sortCatches(filteredList, filterState);

    emit(state.copyWith(displayedCatches: filteredList));
  }

  List<Catch> _sortCatches(List<Catch> list, ProductsFilterState filterState) {
    // Price sort has priority
    if (filterState.sortByPrice != SortBy.none) {
      list.sort((a, b) {
        final priceA = a.pricePerKg;
        final priceB = b.pricePerKg;
        return filterState.sortByPrice == SortBy.highLow
            ? priceB.compareTo(priceA)
            : priceA.compareTo(priceB);
      });
      return list;
    }

    // Date sort if price is not applied
    if (filterState.sortByDate != SortBy.none) {
      list.sort((a, b) {
        final dateA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
        return filterState.sortByDate == SortBy.newOld
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
      });
      return list;
    }

    // Default: newest first
    list.sort((a, b) {
      final dateA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return list;
  }

  // --------------------------------------------------------------------------
  // Helper: set all catches directly (used by BuyerMarketBloc)
  // --------------------------------------------------------------------------
  void setAllCatches(List<Catch> catches) {
    emit(state.copyWith(allCatches: catches, displayedCatches: catches));

    _applyFiltersAndSort();
  }

  @override
  Future<void> close() {
    _filterSubscription.cancel();
    return super.close();
  }
}
