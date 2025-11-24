import '../entities/order.dart';
import '../enums/order_status.dart';
import '../repositories/i_catch_repository.dart';
import '../repositories/i_offer_repository.dart';
import '../repositories/i_order_repository.dart';

/// Service handling order lifecycle operations
class OrderService {
  final IOrderRepository _orderRepository;
  final IOfferRepository _offerRepository;
  final ICatchRepository _catchRepository;

  OrderService({
    required IOrderRepository orderRepository,
    required IOfferRepository offerRepository,
    required ICatchRepository catchRepository,
  }) : _orderRepository = orderRepository,
       _offerRepository = offerRepository,
       _catchRepository = catchRepository;

  /// Get all orders for a user
  Future<List<Order>> getUserOrders(String userId) async {
    return await _orderRepository.getByUserId(userId);
  }

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    return await _orderRepository.getById(orderId);
  }

  /// Mark order as completed
  Future<Order> completeOrder({
    required String orderId,
    required String userId,
  }) async {
    final order = await _orderRepository.getById(orderId);
    if (order == null) {
      throw ArgumentError('Order not found');
    }

    // Validate user is part of the order
    if (order.fisherId != userId && order.buyerId != userId) {
      throw StateError('User is not part of this order');
    }

    if (order.status != OrderStatus.active) {
      throw StateError('Can only complete active orders');
    }

    final completed = order.markAsCompleted();
    await _orderRepository.update(completed);
    return completed;
  }

  /// Cancel an order
  Future<Order> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    final order = await _orderRepository.getById(orderId);
    if (order == null) {
      throw ArgumentError('Order not found');
    }

    // Validate user is part of the order
    if (order.fisherId != userId && order.buyerId != userId) {
      throw StateError('User is not part of this order');
    }

    if (order.status != OrderStatus.active) {
      throw StateError('Can only cancel active orders');
    }

    // Execute in transaction to restore catch weight
    return await _orderRepository.transaction(() async {
      final cancelled = order.markAsCancelled();
      await _orderRepository.update(cancelled);

      // Restore catch available weight
      final catchItem = await _catchRepository.getById(order.catchId);
      if (catchItem != null) {
        final restored = catchItem.copyWith(
          availableWeight: catchItem.availableWeight + order.terms.weight,
        );
        await _catchRepository.update(restored);
      }

      return cancelled;
    });
  }
}
