part of "products_cubit.dart";

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  // ✅ Holds the list of available Catch items for the marketplace
  final List<Catch> availableCatches;

  const ProductsLoaded(this.availableCatches);

  @override
  List<Object> get props => [availableCatches];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}
