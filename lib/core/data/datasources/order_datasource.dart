import 'package:siren_marketplace/core/data/persistence/order_entity.dart';

abstract class OrderDataSource {
  Future<void> insertOrder(OrderEntity entity);

  Future<OrderEntity?> getOrderById(String id);

  Future<List<OrderEntity>> getAllOrders();

  Future<List<OrderEntity>> getOrdersByUserId(String userId);

  Future<void> updateOrder(OrderEntity entity);

  Future<void> deleteOrder(String id);

  Future<OrderEntity?> getOrderByOfferId(String offerId);
}
