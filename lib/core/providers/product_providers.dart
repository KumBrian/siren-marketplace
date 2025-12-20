import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';

final fisherProductsProvider = FutureProvider.family<List<Product>, int>((
  ref,
  page,
) async {
  final repository = sl<IProductRepository>();
  final result = await repository.getFisherProducts(page: page);
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
  final repository = sl<IProductRepository>();
  final result = await repository.getProductOffers(productId);
  return result.fold(
    ifLeft: (failure) => throw failure,
    ifRight: (offers) => offers,
  );
});

final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = sl<IProductRepository>();
  final result = await repository.getAvailableProducts();
  return result.fold(
    ifLeft: (failure) => throw failure,
    ifRight: (products) => products,
  );
});
