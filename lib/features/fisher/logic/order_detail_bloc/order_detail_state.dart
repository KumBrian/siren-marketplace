part of 'order_detail_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderMarkedCompleted extends OrderDetailState {
  final Order order;

  const OrderMarkedCompleted(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  final Catch catchSnapshot;
  final AppUser? buyer;

  const OrderDetailLoaded({
    required this.order,
    required this.catchSnapshot,
    this.buyer,
  });

  @override
  List<Object?> get props => [order, catchSnapshot, buyer];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
