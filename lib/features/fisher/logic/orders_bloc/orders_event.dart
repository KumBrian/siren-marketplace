part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all orders for a specific user (buyer or fisher)
class LoadOrdersForUser extends OrdersEvent {
  final String userId;

  const LoadOrdersForUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetOrderById extends OrdersEvent {
  final String orderId;

  const GetOrderById(this.orderId);

  @override
  List<Object> get props => [orderId];
}

/// Event to mark an order as completed.
/// This will update the underlying Offer's status.
class CompleteOrder extends OrdersEvent {
  final Order order;

  const CompleteOrder({required this.order});

  @override
  List<Object> get props => [order];
}

/// An internal event used by the notifier to trigger a refresh.
class _RefreshOrders extends OrdersEvent {}

class SubmitRating extends OrdersEvent {
  final String orderId;
  final String raterId;
  final String ratedUserId;
  final double ratingValue;
  final String? message;

  const SubmitRating({
    required this.orderId,
    required this.raterId,
    required this.ratedUserId,
    required this.ratingValue,
    this.message,
  });

  @override
  List<Object> get props => [
    orderId,
    raterId,
    ratedUserId,
    ratingValue,
    ?message,
  ];
}
