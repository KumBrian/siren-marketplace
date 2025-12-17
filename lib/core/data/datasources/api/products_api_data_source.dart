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

      // API returns: {"data": {"totalItems": 6, "member": [...]}}
      // So we need to extract data.member
      final responseData = response.data['data'];
      final List<dynamic> products = responseData['member'] ?? [];

      print('DEBUG: Parsing ${products.length} products from member array');

      return products.map((json) => ProductApiModel.fromJson(json)).toList();
    } catch (e) {
      print('ERROR: Failed to fetch fisher products: $e');
      rethrow;
    }
  }
}
