import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/data/datasources/api/products_api_data_source.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../mappers/product_mapper.dart';
import '../mappers/offer_api_mapper.dart';
import '../mappers/offer_mapper.dart';

import '../../services/connectivity_service.dart';
import '../../data/datasources/local/local_product_datasource.dart';
import '../../data/models/product_model.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ProductsApiDataSource _remoteDataSource;
  final LocalProductDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  ProductRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivityService,
  );

  Future<bool> get _isOffline async {
    final status = await _connectivityService.checkConnectivity();
    return status == NetworkStatus.offline;
  }

  @override
  Future<Either<Failure, List<Product>>> getFisherProducts({
    int page = 1,
    String? userId,
  }) async {
    if (await _isOffline) {
      if (userId == null) {
        return Left(CacheFailure(message: 'User ID required for offline mode'));
      }
      try {
        final localModels = await _localDataSource.getProductsByFisherId(
          userId,
        );
        final products = localModels.map((m) => m.toDomain()).toList();
        return Right(products);
      } catch (e) {
        return Left(CacheFailure(message: 'Could not fetch offline products'));
      }
    }

    try {
      final apiModels = await _remoteDataSource.getFisherProducts(page: page);
      final products = apiModels
          .map((model) => ProductMapper.toDomain(model))
          .toList();

      // Cache locally
      try {
        await _localDataSource.saveBatch(
          products.map((p) => ProductModel.fromDomain(p)).toList(),
        );
        print(
          'DEBUG ProductRepository: Successfully cached ${products.length} fisher products',
        );
      } catch (e) {
        print('DEBUG ProductRepository: Failed to cache fisher products: $e');
        // Ignore cache failure
      }

      return Right(products);
    } catch (e) {
      // Fallback to local if API fails
      if (userId != null) {
        try {
          final localModels = await _localDataSource.getProductsByFisherId(
            userId,
          );
          if (localModels.isNotEmpty) {
            final products = localModels.map((m) => m.toDomain()).toList();
            return Right(products);
          }
        } catch (localError) {
          print('DEBUG ProductRepository: Fallback failed: $localError');
        }
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    if (await _isOffline) {
      try {
        final localModel = await _localDataSource.getProductById(id);
        if (localModel != null) {
          return Right(localModel.toDomain());
        }
        return const Right(null);
      } catch (e) {
        // Fallback or ignore
        return Left(CacheFailure(message: 'Offline product not found locally'));
      }
    }

    try {
      final apiModel = await _remoteDataSource.getProductById(id);
      final product = ProductMapper.toDomain(apiModel);

      // Cache locally
      try {
        await _localDataSource.saveBatch([ProductModel.fromDomain(product)]);
      } catch (e) {
        // Ignore cache failure
      }

      return Right(product);
    } catch (e) {
      // Fallback to local if API fails (even if we thought we were online)
      try {
        final localModel = await _localDataSource.getProductById(id);
        if (localModel != null) {
          return Right(localModel.toDomain());
        }
      } catch (_) {}
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
    if (await _isOffline) {
      try {
        final localModels = await _localDataSource.getAllProducts();
        final products = localModels
            .map((m) => m.toDomain())
            // Filter only available items (not sold AND not expired)
            .where((p) => !p.isSold && p.daysLeft > 0)
            .toList();
        return Right(products);
      } catch (e) {
        return Left(CacheFailure(message: 'Could not fetch offline products'));
      }
    }

    try {
      final apiModels = await _remoteDataSource.getAvailableProducts();
      final products = apiModels
          .map((model) => ProductMapper.toDomain(model))
          .toList();

      // Cache locally
      try {
        await _localDataSource.saveBatch(
          products.map((p) => ProductModel.fromDomain(p)).toList(),
        );
      } catch (e) {
        // Ignore cache failure
      }

      return Right(products);
    } catch (e) {
      // Fallback to local if API fails
      try {
        final localModels = await _localDataSource.getAllProducts();
        if (localModels.isNotEmpty) {
          final products = localModels
              .map((m) => m.toDomain())
              .where((p) => !p.isSold && p.daysLeft > 0)
              .toList();
          return Right(products);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
