import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/exceptions/not_found_exception.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/interfaces/i_order_datasource.dart';
import '../datasources/api/orders_api_data_source.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderDataSource dataSource;

  OrderRepositoryImpl({required this.dataSource});

  @override
  Future<String> create(Order order) async {
    final model = OrderMapper.toModel(order);
    return await dataSource.create(model);
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final models = await dataSource.getAllOrders();
    return models.map((m) => OrderMapper.toEntity(m)).toList();
  }

  @override
  Future<Order> getById(String orderId) async {
    // Use embedded data fetch if available
    final order = await getByIdWithEmbeddedData(orderId);
    if (order == null) {
      throw NotFoundException(
        "Order not found",
        entityType: 'Order',
        entityId: orderId,
      );
    }
    return order;
  }

  @override
  Future<Order?> getByOfferId(String offerId) async {
    final model = await dataSource.getByOfferId(offerId);
    return model != null ? OrderMapper.toEntity(model) : null;
  }

  @override
  Future<List<Order>> getByUserId(String userId) async {
    final models = await dataSource.getByUserId(userId);
    return models.map((m) => OrderMapper.toEntity(m)).toList();
  }

  /// Get orders with embedded product data (more efficient, no extra fetches needed)
  Future<List<Order>> getByUserIdWithEmbeddedData(String userId) async {
    print(
      '🔄 REPO: getByUserIdWithEmbeddedData called, dataSource type: ${dataSource.runtimeType}',
    );
    // Cast to access the new method
    if (dataSource is OrdersApiDataSource) {
      final apiModels = await (dataSource as OrdersApiDataSource)
          .getOrdersWithEmbeddedData(userId);
      return apiModels.map((api) => OrderMapper.fromApi(api)).toList();
    }
    // Fallback to old method
    return getByUserId(userId);
  }

  /// Get single order by ID with embedded product data (more efficient)
  Future<Order?> getByIdWithEmbeddedData(String orderId) async {
    // Cast to access the new method
    if (dataSource is OrdersApiDataSource) {
      final apiModel = await (dataSource as OrdersApiDataSource)
          .getByIdWithEmbeddedData(orderId);
      return apiModel != null ? OrderMapper.fromApi(apiModel) : null;
    }
    // Fallback to old method
    return getById(orderId);
  }

  @override
  Future<List<Order>> getByFisherId(String fisherId) async {
    final models = await dataSource.getByFisherId(fisherId);
    return models.map((m) => OrderMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Order>> getByBuyerId(String buyerId) async {
    final models = await dataSource.getByBuyerId(buyerId);
    return models.map((m) => OrderMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Order>> getByStatus(OrderStatus status) async {
    final models = await dataSource.getByStatus(status);
    return models.map((m) => OrderMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Order>> getReviewableOrders(String userId) async {
    final completed = await getByStatus(OrderStatus.completed);
    return completed.where((o) => o.canBeReviewedBy(userId)).toList();
  }

  @override
  Future<void> update(Order order) async {
    final model = OrderMapper.toModel(order);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String orderId) async {
    await dataSource.delete(orderId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }

  @override
  Future<Order> relistOrder(String orderId, String cancellationReason) async {
    final model = await dataSource.relistOrder(orderId, cancellationReason);
    if (model == null) {
      throw Exception('Failed to relist order');
    }
    return OrderMapper.toEntity(model);
  }
}
