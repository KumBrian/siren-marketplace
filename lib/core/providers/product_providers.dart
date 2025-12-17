import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/injector.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/i_product_repository.dart';

final fisherProductsProvider = FutureProvider.autoDispose
    .family<List<Product>, int>((ref, page) async {
      final repository = sl<IProductRepository>();
      final result = await repository.getFisherProducts(page: page);
      return result.fold(
        ifLeft: (failure) => throw failure,
        ifRight: (products) => products,
      );
    });
