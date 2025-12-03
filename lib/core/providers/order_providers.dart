import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/domain/services/order_service.dart';

/// Provider to fetch an Order by ID
final orderProvider = FutureProvider.family<Order?, String>((ref, id) async {
  final repository = sl<IOrderRepository>();
  // Repository returns Future<Order>, but we want nullable for consistency/safety
  try {
    return await repository.getById(id);
  } catch (_) {
    return null;
  }
});

/// Provider to fetch orders for the current user
final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final repository = sl<IOrderRepository>();
  return repository.getByUserId(user.id);
});

/// Provider to fetch orders for the current fisher user
/// Automatically refreshes when user changes
final fisherOrdersProvider = FutureProvider.autoDispose<List<Order>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final repository = sl<IOrderRepository>();
  return repository.getByUserId(user.id);
});

/// Provider to calculate turnover from completed orders
/// Derived state that automatically updates
final fisherTurnoverProvider = Provider.autoDispose<double>((ref) {
  final ordersAsync = ref.watch(fisherOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0, (sum, o) => sum + o.terms.totalPrice.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Provider to complete an order
/// Returns the updated order after completion
final completeOrderProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final repository = sl<IOrderRepository>();
  final order = await repository.getById(orderId);

  // Update order status to completed
  final completedOrder = order.copyWith(status: OrderStatus.completed);
  await repository.update(completedOrder);

  // Update related offer status to completed
  final offerRepository = sl<IOfferRepository>();
  final offer = await offerRepository.getById(order.offerId);
  if (offer != null) {
    final completedOffer = offer.copyWith(
      status: OfferStatus.completed,
      waitingFor: null,
    );
    await offerRepository.update(completedOffer);
  }

  // Invalidate related providers to refresh data
  ref.invalidate(orderProvider(orderId));
  ref.invalidate(fisherOrdersProvider);
  ref.invalidate(offerProvider(order.offerId));

  return completedOrder;
});

/// Provider to cancel an order
final cancelOrderProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) throw Exception('User not logged in');

  final orderService = sl<OrderService>();
  final cancelledOrder = await orderService.cancelOrder(
    orderId: orderId,
    userId: user.id,
  );

  // Invalidate related providers to refresh data
  ref.invalidate(orderProvider(orderId));
  ref.invalidate(fisherOrdersProvider);
  // TODO: Add fisherOffersProvider import and invalidate
  // ref.invalidate(fisherOffersProvider); // Also invalidate offers

  return cancelledOrder;
});
