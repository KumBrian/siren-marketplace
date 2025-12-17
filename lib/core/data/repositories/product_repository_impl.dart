import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/data/datasources/api/products_api_data_source.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../mappers/product_mapper.dart';

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
      // Basic error handling
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
