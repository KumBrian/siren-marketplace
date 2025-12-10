import '../../../../core/domain/enums/order_status.dart';
import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/order_api_models.dart';
import '../../../../core/data/mappers/order_api_mapper.dart';
import '../../models/order_model.dart';
import '../interfaces/i_order_datasource.dart';

class OrdersApiDataSource implements IOrderDataSource {
  final ApiClient _client;

  OrdersApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<List<OrderModel>> getAllOrders() async {
    // Admin function, or fallback to my orders
    return getByUserId('');
  }

  @override
  Future<List<OrderModel>> getByUserId(String userId) async {
    final response = await _client.get(
      ApiConfig.mySaleOrders,
      queryParameters: {'page': 1, 'itemsPerPage': 20},
    );

    final rawData = response.data;
    List listData = [];
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map) {
      listData = rawData['data']?['member'] ?? rawData['data'] ?? [];
    }

    return listData
        .map((json) => OrderApiMapper.toDomain(OrderApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<OrderModel?> getById(String orderId) async {
    try {
      final response = await _client.get(ApiConfig.saleOrder(orderId));
      final data = response.data['data'] ?? response.data;
      return OrderApiMapper.toDomain(OrderApiModel.fromJson(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> create(OrderModel order) async {
    final response = await _client.post(
      ApiConfig.saleOrdersCreate,
      data: OrderApiMapper.toCreateBody(order),
    );
    // Assuming response contains created ID
    final data = response.data['data'] ?? response.data;
    return data['id'].toString();
  }

  @override
  Future<void> update(OrderModel order) async {
    // TODO: Implement update
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String orderId) async {
    // TODO: Implement delete
    throw UnimplementedError();
  }

  @override
  Future<OrderModel?> getByOfferId(String offerId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<OrderModel>> getByFisherId(String fisherId) async {
    // API might support filtering by fisher_id
    // For now, throw or return empty
    return [];
  }

  @override
  Future<List<OrderModel>> getByBuyerId(String buyerId) async {
    // Likely same endpoint as my-orders if I am the buyer?
    return [];
  }

  @override
  Future<List<OrderModel>> getByStatus(OrderStatus status) async {
    return [];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return action();
  }
}
