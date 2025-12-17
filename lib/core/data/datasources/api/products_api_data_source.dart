import 'package:dio/dio.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/models/product_api_models.dart';

class ProductsApiDataSource {
  final ApiClient _client;

  ProductsApiDataSource(this._client);

  Future<List<ProductApiModel>> getFisherProducts({required int page}) async {
    final response = await _client.get(
      '/products/my-products',
      queryParameters: {'page': page, 'itemsPerPage': 20},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ProductApiModel.fromJson(json)).toList();
    } else {
      // ApiClient might throw ApiException, but if we get here with non-200 that didn't throw:
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
