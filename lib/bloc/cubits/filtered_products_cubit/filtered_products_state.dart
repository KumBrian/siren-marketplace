part of 'filtered_products_cubit.dart';

class FilteredProductsState extends Equatable {
  final List<Catch> allCatches;
  final List<Catch> displayedCatches;
  final List<Species> uniqueSpecies;
  final List<String> uniqueLocations;
  final bool isLoading;
  final String? errorMessage;

  const FilteredProductsState({
    this.allCatches = const [],
    this.displayedCatches = const [],
    this.uniqueSpecies = const [],
    this.uniqueLocations = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FilteredProductsState copyWith({
    List<Catch>? allCatches,
    List<Catch>? displayedCatches,
    List<Species>? uniqueSpecies,
    List<String>? uniqueLocations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FilteredProductsState(
      allCatches: allCatches ?? this.allCatches,
      displayedCatches: displayedCatches ?? this.displayedCatches,
      uniqueSpecies: uniqueSpecies ?? this.uniqueSpecies,
      uniqueLocations: uniqueLocations ?? this.uniqueLocations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    allCatches,
    displayedCatches,
    uniqueSpecies,
    uniqueLocations,
    isLoading,
    errorMessage,
  ];
}
