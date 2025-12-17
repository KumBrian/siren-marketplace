import 'package:dio/dio.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/models/product_api_models.dart';

class ProductsApiDataSource {
  final ApiClient _client;

  ProductsApiDataSource(this._client);

  Future<List<ProductApiModel>> getFisherProducts({required int page}) async {
    try {
      final response = await _client.get(
        '/products/my-products',
        queryParameters: {'page': page, 'itemsPerPage': 20},
      );

      print('DEBUG: Products API response status: ${response.statusCode}');
      print(
        'DEBUG: Products API response data type: ${response.data.runtimeType}',
      );

      // API returns array directly, not wrapped in {data: [...]}
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);

      print('DEBUG: Parsing ${data.length} products');

      return data.map((json) => ProductApiModel.fromJson(json)).toList();
    } catch (e) {
      print('ERROR: Failed to fetch fisher products: $e');
      rethrow;
    }
  }
}
