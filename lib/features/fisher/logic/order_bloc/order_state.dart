part of "order_bloc.dart";

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

// 🆕 NEW STATE
class SingleOrderLoaded extends OrdersState {
  final Order order;

  const SingleOrderLoaded(this.order);

  @override
  List<Object> get props => [order];
}
