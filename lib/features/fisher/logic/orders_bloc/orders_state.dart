part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class MarkedAsCompleted extends OrdersState {}

/// State for when the list of all orders is loaded.
class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

/// 🆕 NEW STATE: For when a single order's details are loaded.
class OrderDetailsLoaded extends OrdersState {
  final Order order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}
