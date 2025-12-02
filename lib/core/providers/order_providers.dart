import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';

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

  // Invalidate related providers to refresh data
  ref.invalidate(orderProvider(orderId));
  ref.invalidate(fisherOrdersProvider);

  return completedOrder;
});

/// Provider to cancel an order
final cancelOrderProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
  final orderRepository = sl<IOrderRepository>();
  final offerRepository = sl<IOfferRepository>();
  final catchRepository = sl<ICatchRepository>();

  final order = await orderRepository.getById(orderId);

  // 1. Update Offer status to cancelled
  final offerToUpdate = await offerRepository.getById(order.offerId);
  if (offerToUpdate != null) {
    final cancelledOffer = offerToUpdate.copyWith(
      status: OfferStatus.cancelled,
      waitingFor: null,
    );
    await offerRepository.update(cancelledOffer);
  }

  // 2. Update Order status to cancelled
  final cancelledOrder = order.markAsCancelled();
  await orderRepository.update(cancelledOrder);

  // 3. Restore Catch weight
  final catchItem = await catchRepository.getById(order.catchId);
  if (catchItem != null) {
    final restoredCatch = catchItem.copyWith(
      availableWeight: catchItem.availableWeight + order.terms.weight,
    );
    await catchRepository.update(restoredCatch);
  }

  // Invalidate related providers to refresh data
  ref.invalidate(orderProvider(orderId));
  ref.invalidate(fisherOrdersProvider);
  // TODO: Add fisherOffersProvider import and invalidate
  // ref.invalidate(fisherOffersProvider); // Also invalidate offers

  return cancelledOrder;
});
