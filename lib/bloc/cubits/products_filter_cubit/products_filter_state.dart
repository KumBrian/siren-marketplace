part of 'products_filter_cubit.dart';

class ProductsFilterState extends Equatable {
  final List<Species> selectedSpecies;
  final List<String> selectedLocations;
  final SortBy sortByDate;
  final SortBy sortByPrice;

  const ProductsFilterState({
    this.selectedSpecies = const [],
    this.selectedLocations = const [],
    this.sortByDate = SortBy.none,
    this.sortByPrice = SortBy.none,
  });

  ProductsFilterState copyWith({
    List<Species>? selectedSpecies,
    List<String>? selectedLocations,
    SortBy? sortByDate,
    SortBy? sortByPrice,
  }) {
    return ProductsFilterState(
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      sortByDate: sortByDate ?? this.sortByDate,
      sortByPrice: sortByPrice ?? this.sortByPrice,
    );
  }

  @override
  List<Object?> get props => [
    selectedSpecies,
    selectedLocations,
    sortByDate,
    sortByPrice,
  ];
}
