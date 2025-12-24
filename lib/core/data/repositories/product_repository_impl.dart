import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/data/datasources/api/products_api_data_source.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../mappers/product_mapper.dart';
import '../mappers/offer_api_mapper.dart';
import '../mappers/offer_mapper.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ProductsApiDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getFisherProducts({
    int page = 1,
  }) async {
    try {
      final apiModels = await _remoteDataSource.getFisherProducts(page: page);
      final products = apiModels
          .map((model) => ProductMapper.toDomain(model))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    try {
      final apiModel = await _remoteDataSource.getProductById(id);
      final product = ProductMapper.toDomain(apiModel);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Offer>>> getProductOffers(
    String productId,
  ) async {
    try {
      final apiModels = await _remoteDataSource.getProductOffers(productId);
      // Map: OfferApiModel → OfferModel → Offer
      final offers = apiModels
          .map((apiModel) => OfferApiMapper.toDomain(apiModel))
          .map((model) => OfferMapper.toEntity(model))
          .toList();
      return Right(offers);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    String id, {
    required double pricePerKg,
    required double finalPrice,
    required double availableWeight,
  }) async {
    try {
      final body = {
        'price_per_kg': pricePerKg,
        'final_price': finalPrice,
        'available_weight': availableWeight,
      };

      final apiModel = await _remoteDataSource.updateProduct(id, body);
      final product = ProductMapper.toDomain(apiModel);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAvailableProducts() async {
    try {
      final apiModels = await _remoteDataSource.getAvailableProducts();
      final products = apiModels
          .map((model) => ProductMapper.toDomain(model))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
