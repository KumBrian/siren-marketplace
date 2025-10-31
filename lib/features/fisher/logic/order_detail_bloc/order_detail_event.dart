part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetails extends OrderDetailEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ClearOrderDetails extends OrderDetailEvent {}

class MarkOrderAsCompleted extends OrderDetailEvent {
  final Order order;

  const MarkOrderAsCompleted(this.order);

  @override
  List<Object> get props => [order];
}
