import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/buyer/data/buyer_repository.dart';

part 'buyer_market_event.dart';
part 'buyer_market_state.dart';

class BuyerMarketBloc extends Bloc<BuyerMarketEvent, BuyerMarketState> {
  final BuyerRepository repository;
  List<Catch> _lastFetchedCatches = [];
  List<Species>? _lastSpeciesFilter;
  List<String>? _lastLocationFilter;
  SortBy? _lastSortByDate;
  SortBy? _lastSortByPrice;

  BuyerMarketBloc(this.repository) : super(BuyerMarketInitial()) {
    on<LoadMarketCatches>(_onLoadMarketCatches);
    on<RefreshMarketCatches>(_onRefreshMarketCatches);
  }

  Future<void> _onLoadMarketCatches(
    LoadMarketCatches event,
    Emitter<BuyerMarketState> emit,
  ) async {
    emit(BuyerMarketLoading());

    try {
      final catches = await repository.getMarketCatches();
      _lastFetchedCatches = catches;

      // Save filters
      _lastSpeciesFilter = event.speciesFilter;
      _lastLocationFilter = event.locationFilter;
      _lastSortByDate = event.sortByDate;
      _lastSortByPrice = event.sortByPrice;

      // Apply filters & sorting
      final filtered = _applyFiltersAndSort(
        catches,
        speciesFilter: event.speciesFilter,
        locationFilter: event.locationFilter,
        sortByDate: event.sortByDate,
        sortByPrice: event.sortByPrice,
      );

      emit(BuyerMarketLoaded(filtered));
    } catch (e, st) {
      emit(BuyerMarketError("Failed to load market catches: $e"));
      debugPrintStack(label: 'BuyerMarketBloc', stackTrace: st);
    }
  }

  Future<void> _onRefreshMarketCatches(
    RefreshMarketCatches event,
    Emitter<BuyerMarketState> emit,
  ) async {
    // Reapply filters/sorting on the last fetched catches
    final filtered = _applyFiltersAndSort(
      _lastFetchedCatches,
      speciesFilter: _lastSpeciesFilter,
      locationFilter: _lastLocationFilter,
      sortByDate: _lastSortByDate,
      sortByPrice: _lastSortByPrice,
    );

    emit(BuyerMarketLoaded(filtered));
  }

  List<Catch> _applyFiltersAndSort(
    List<Catch> catches, {
    List<Species>? speciesFilter,
    List<String>? locationFilter,
    SortBy? sortByDate,
    SortBy? sortByPrice,
  }) {
    List<Catch> filtered = List.from(catches);

    // Filter species
    if (speciesFilter != null && speciesFilter.isNotEmpty) {
      final ids = speciesFilter.map((s) => s.id).toSet();
      filtered = filtered.where((c) => ids.contains(c.species.id)).toList();
    }

    // Filter location
    if (locationFilter != null && locationFilter.isNotEmpty) {
      final locations = locationFilter.toSet();
      filtered = filtered.where((c) => locations.contains(c.market)).toList();
    }

    // Sort by price
    if (sortByPrice != null && sortByPrice != SortBy.none) {
      filtered.sort((a, b) {
        if (sortByPrice == SortBy.lowHigh) {
          return a.pricePerKg.compareTo(b.pricePerKg);
        }
        return b.pricePerKg.compareTo(a.pricePerKg);
      });
    }
    // Sort by date
    else if (sortByDate != null && sortByDate != SortBy.none) {
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
        if (sortByDate == SortBy.oldNew) return dateA.compareTo(dateB);
        return dateB.compareTo(dateA); // newest first
      });
    } else {
      // Default: newest first
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a.datePosted) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.datePosted) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    }

    return filtered;
  }
}
