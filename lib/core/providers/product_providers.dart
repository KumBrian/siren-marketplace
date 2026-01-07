import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';

final fisherProductsProvider = FutureProvider.family<List<Product>, int>((
  ref,
  page,
) async {
  final user = await ref.watch(currentUserProvider.future);
  final repository = sl<IProductRepository>();
  final result = await repository.getFisherProducts(
    page: page,
    userId: user?.id,
  );
  return result.fold(
    ifLeft: (failure) => throw failure,
    ifRight: (products) => products,
  );
});

final productByIdProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final repository = sl<IProductRepository>();
  final result = await repository.getProductById(id);
  return result.fold(
    ifLeft: (failure) => throw failure,
    ifRight: (product) => product,
  );
});

final productOffersProvider = FutureProvider.family<List<Offer>, String>((
  ref,
  productId,
) async {
  // Use OfferRepository instead of ProductRepository to get viewed state management
  // Get current user to determine role context
  final user = await ref.watch(currentUserProvider.future);
  final role = user?.currentRole;

  final offerRepository = sl<IOfferRepository>();
  return offerRepository.getByProductId(productId, role: role);
});

final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = sl<IProductRepository>();
  final result = await repository.getAvailableProducts();
  return result.fold(
    ifLeft: (failure) => throw failure,
    ifRight: (products) => products,
  );
});
