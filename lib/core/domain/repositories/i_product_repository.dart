import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

abstract class IProductRepository {
  Future<Either<Failure, List<Product>>> getFisherProducts({int page = 1});
}
