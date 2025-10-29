import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';

part 'products_filter_state.dart';

class ProductsFilterCubit extends Cubit<ProductsFilterState> {
  ProductsFilterCubit() : super(const ProductsFilterState());

  void setSpecies(List<Species> species) {
    emit(state.copyWith(selectedSpecies: species, applyFilters: false));
  }

  void setLocations(List<String> locations) {
    emit(state.copyWith(selectedLocations: locations, applyFilters: false));
  }

  void setMinWeight(double? minWeight) {
    emit(state.copyWith(minWeight: minWeight, applyFilters: false));
  }

  void setSortPrice(SortBy sortBy) {
    emit(state.copyWith(sortByPrice: sortBy, applyFilters: false));
  }

  void setSortDate(SortBy sortBy) {
    emit(state.copyWith(sortByDate: sortBy, applyFilters: false));
  }

  void clear() {
    emit(const ProductsFilterState());
  }

  void applyFilters() {
    final updatedState = _recalculateFilters(
      state,
    ).copyWith(applyFilters: true);
    emit(updatedState);
  }

  ProductsFilterState _recalculateFilters(ProductsFilterState newState) {
    int total = 0;
    if (newState.selectedSpecies.isNotEmpty) total++;
    if (newState.selectedLocations.isNotEmpty) total++;
    if (newState.minWeight > 0) total++;
    return newState.copyWith(totalFilters: total);
  }
}
