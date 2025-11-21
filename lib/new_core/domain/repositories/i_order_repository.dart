import '../entities/order.dart';
import '../enums/order_status.dart';

abstract class IOrderRepository {
  /// Create a new order
  Future<String> create(Order order);

  /// Get order by ID
  Future<Order?> getById(String orderId);

  /// Get order by offer ID
  Future<Order?> getByOfferId(String offerId);

  /// Get all orders for a user (as fisher or buyer)
  Future<List<Order>> getByUserId(String userId);

  /// Get orders by fisher ID
  Future<List<Order>> getByFisherId(String fisherId);

  /// Get orders by buyer ID
  Future<List<Order>> getByBuyerId(String buyerId);

  /// Get orders by status
  Future<List<Order>> getByStatus(OrderStatus status);

  /// Get completed orders that can be reviewed by user
  Future<List<Order>> getReviewableOrders(String userId);

  /// Update order
  Future<void> update(Order order);

  /// Delete order
  Future<void> delete(String orderId);

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function() action);
}
