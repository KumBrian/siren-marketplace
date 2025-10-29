part of 'products_filter_cubit.dart';

class ProductsFilterState extends Equatable {
  final List<Species> selectedSpecies;
  final List<String> selectedLocations;
  final double minWeight;
  final SortBy sortByPrice;
  final SortBy sortByDate;
  final bool applyFilters;
  final int totalFilters;

  const ProductsFilterState({
    this.selectedSpecies = const [],
    this.selectedLocations = const [],
    this.minWeight = 0,
    this.sortByPrice = SortBy.none,
    this.sortByDate = SortBy.none,
    this.applyFilters = false,
    this.totalFilters = 0,
  });

  ProductsFilterState copyWith({
    List<Species>? selectedSpecies,
    List<String>? selectedLocations,
    double? minWeight,
    SortBy? sortByPrice,
    SortBy? sortByDate,
    bool? applyFilters,
    int? totalFilters,
  }) {
    return ProductsFilterState(
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      minWeight: minWeight ?? this.minWeight,
      sortByPrice: sortByPrice ?? this.sortByPrice,
      sortByDate: sortByDate ?? this.sortByDate,
      applyFilters: applyFilters ?? this.applyFilters,
      totalFilters: totalFilters ?? this.totalFilters,
    );
  }

  @override
  List<Object?> get props => [
    selectedSpecies,
    selectedLocations,
    minWeight,
    sortByPrice,
    sortByDate,
    applyFilters,
    totalFilters,
  ];
}
