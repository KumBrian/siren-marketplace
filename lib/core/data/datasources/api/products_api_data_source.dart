import 'package:dio/dio.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import '../../api/models/product_api_models.dart';
import '../../api/models/offer_api_models.dart';

class ProductsApiDataSource {
  final ApiClient _client;

  ProductsApiDataSource(this._client);

  Future<List<ProductApiModel>> getFisherProducts({int page = 1}) async {
    try {
      final response = await _client.get(
        ApiConfig.myProducts,
        queryParameters: {'page': page, 'itemsPerPage': 30},
      );

      // Adaptation: The API returns Hydra collection for my-fish-catches usually
      final data = response.data;
      final List<dynamic> members;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        // Assuming standard envelope
        final internalData = data['data'];
        if (internalData is Map<String, dynamic> &&
            internalData.containsKey('member')) {
          members = internalData['member'] ?? [];
        } else if (internalData is List) {
          members = internalData;
        } else {
          members = [];
        }
      } else {
        members = [];
      }

      return members.map((json) => ProductApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductApiModel> getProductById(String id) async {
    try {
      // "Retrieving product details" - assuming mapped to fish-catches/{id} or products/{id}
      // User said "use the product...".
      // If we use /api/v1/products/{id}, we need to be sure it exists.
      // The user prompt mentions: "GET /api/v1/products/{id}/offers".
      // So likely /api/v1/products/{id} also exists.
      final response = await _client.get('${ApiConfig.products}/$id');

      // Response likely wraps data in 'data'
      final data = response.data['data'] ?? response.data;
      return ProductApiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OfferApiModel>> getProductOffers(String productId) async {
    try {
      final response = await _client.get(
        '${ApiConfig.products}/$productId/offers',
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => OfferApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete(ApiConfig.productDelete(id));
  }

  Future<ProductApiModel> updateProduct(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.patch(
      ApiConfig.productUpdate(id),
      data: body,
      options: Options(contentType: 'application/merge-patch+json'),
    );
    return ProductApiModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ProductApiModel>> getAvailableProducts() async {
    final response = await _client.get(ApiConfig.productsAvailable);
    final data = response.data['data'] ?? response.data;
    final List list = data is List ? data : (data['member'] ?? []);
    return list.map((json) => ProductApiModel.fromJson(json)).toList();
  }
}
