part of 'buyer_orders_bloc.dart';

abstract class BuyerOrdersState {}

class BuyerOrdersInitial extends BuyerOrdersState {}

class BuyerOrdersLoading extends BuyerOrdersState {}

class BuyerOrdersLoaded extends BuyerOrdersState {
  final List<Order> orders;

  BuyerOrdersLoaded(this.orders);
}

class BuyerOrdersError extends BuyerOrdersState {
  final String message;

  BuyerOrdersError(this.message);
}
