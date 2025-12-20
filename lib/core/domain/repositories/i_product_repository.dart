import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<Product>>> getFisherProducts({int page = 1});
  Future<Either<Failure, Product?>> getProductById(String id);
  Future<Either<Failure, List<Offer>>> getProductOffers(String productId);
  Future<Either<Failure, bool>> deleteProduct(String id);
  Future<Either<Failure, Product>> updateProduct(
    String id, {
    required double pricePerKg,
    required double finalPrice,
    required double availableWeight,
  });

  /// Get available products for buyers
  Future<Either<Failure, List<Product>>> getAvailableProducts();
}
