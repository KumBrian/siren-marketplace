import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final CatchRepository _catchRepository;

  ProductsCubit(this._catchRepository) : super(ProductsInitial());

  // Method to load all available Catch items for the marketplace
  Future<void> loadMarketCatches() async {
    try {
      emit(ProductsLoading());

      // 1. Get the raw list (which might be the shared/mutable source)
      final rawCatches = await _catchRepository.fetchMarketCatches();

      // 2. 💡 CRITICAL FIX: Deep-copy every object to ensure the Buyer widget tree
      // receives its own immutable, non-shared instance.
      final isolatedCatches = rawCatches
          .map((c) => c.copyWith())
          .toList(growable: false); // Make the list fixed-length for safety

      emit(ProductsLoaded(isolatedCatches));
    } catch (e) {
      emit(ProductsError('Failed to load products: $e'));
    }
  }

  // Optionally, a method to refresh the data
  Future<void> refreshMarketCatches() async {
    // If we're already loaded, we go back to loading to force a UI refresh
    if (state is ProductsLoaded || state is ProductsError) {
      await loadMarketCatches();
    }
  }
}
