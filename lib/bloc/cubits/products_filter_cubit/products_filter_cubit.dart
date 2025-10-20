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
    emit(state.copyWith(minWeight: minWeight ?? 0, applyFilters: false));
  }

  // Independent sort setters — allow both to exist together
  void setSortPrice(SortBy sortBy) {
    emit(state.copyWith(sortByPrice: sortBy, applyFilters: false));
  }

  void setSortDate(SortBy sortBy) {
    emit(state.copyWith(sortByDate: sortBy, applyFilters: false));
  }

  // Clear all filters and sorts
  void clear() {
    emit(
      state.copyWith(
        selectedSpecies: [],
        selectedLocations: [],
        minWeight: null,
        sortByDate: SortBy.none,
        sortByPrice: SortBy.none,
        applyFilters: false,
      ),
    );
  }

  // Trigger actual filtering in FilteredProductsCubit
  void applyFilters() {
    emit(state.copyWith(applyFilters: true));
  }
}
