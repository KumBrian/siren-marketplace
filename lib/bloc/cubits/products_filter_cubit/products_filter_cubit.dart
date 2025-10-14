import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';

part 'products_filter_state.dart';

class ProductsFilterCubit extends Cubit<ProductsFilterState> {
  ProductsFilterCubit() : super(const ProductsFilterState());

  void setSpecies(List<Species> species) {
    emit(state.copyWith(selectedSpecies: species));
  }

  void setLocations(List<String> locations) {
    emit(state.copyWith(selectedLocations: locations));
  }

  void setSortDate(SortBy sortDate) {
    emit(state.copyWith(sortByDate: sortDate));
  }

  void setSortPrice(SortBy sortPrice) {
    emit(state.copyWith(sortByPrice: sortPrice));
  }

  void clear() {
    emit(const ProductsFilterState());
  }
}
