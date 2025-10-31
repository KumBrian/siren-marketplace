part of 'order_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object> get props => [];
}

// Existing event examples (assuming these exist):
class LoadOrders extends OrdersEvent {}

class AddOrder extends OrdersEvent {
  final Order order;

  const AddOrder(this.order);

  @override
  List<Object> get props => [order];
}

class DeleteOrderEvent extends OrdersEvent {
  final String orderId;

  const DeleteOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class GetOrderByOfferId extends OrdersEvent {
  final String offerId;

  const GetOrderByOfferId(this.offerId);

  @override
  List<Object> get props => [offerId];
}

// 🆕 NEW REQUIRED EVENT: Load orders filtered by a specific Fisher ID.
class LoadAllFisherOrders extends OrdersEvent {
  final String userId;

  const LoadAllFisherOrders({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetOrderById extends OrdersEvent {
  final String orderId;

  const GetOrderById(this.orderId);

  @override
  List<Object> get props => [orderId];
}

// class MarkOrderAsCompleted extends OrdersEvent {
//   final Order order;
//
//   const MarkOrderAsCompleted(this.order);
//
//   @override
//   List<Object> get props => [order];
// }

class UpdateOrder extends OrdersEvent {
  final Order updatedOrder;

  const UpdateOrder(this.updatedOrder);

  @override
  List<Object> get props => [updatedOrder];
}
