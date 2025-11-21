import '../../../domain/enums/order_status.dart';
import '../../models/order_model.dart';

abstract class IOrderDataSource {
  Future<String> create(OrderModel order);

  Future<OrderModel?> getById(String orderId);

  Future<OrderModel?> getByOfferId(String offerId);

  Future<List<OrderModel>> getByUserId(String userId);

  Future<List<OrderModel>> getByFisherId(String fisherId);

  Future<List<OrderModel>> getByBuyerId(String buyerId);

  Future<List<OrderModel>> getByStatus(OrderStatus status);

  Future<void> update(OrderModel order);

  Future<void> delete(String orderId);

  // Transaction support
  Future<T> transaction<T>(Future<T> Function() action);
}
