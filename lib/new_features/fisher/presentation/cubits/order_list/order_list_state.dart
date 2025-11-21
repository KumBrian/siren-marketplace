import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/new_core/domain/entities/order.dart';

abstract class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

class OrderListInitial extends OrderListState {
  const OrderListInitial();
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListLoaded extends OrderListState {
  final List<Order> orders;

  const OrderListLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderListError extends OrderListState {
  final String message;

  const OrderListError(this.message);

  @override
  List<Object?> get props => [message];
}
