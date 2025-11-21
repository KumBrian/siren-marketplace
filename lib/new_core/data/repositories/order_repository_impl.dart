import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/interfaces/i_order_datasource.dart';
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
  Future<Order?> getById(String orderId) async {
    final model = await dataSource.getById(orderId);
    return model != null ? OrderMapper.toEntity(model) : null;
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
}
