part of 'orders_cubit.dart';

class OrdersState extends Equatable {
  final List<Order> orders;
  final Order? selectedOrder;
  final bool loading;
  final String? error;
  final String? ratingSubmittedFor; // User ID that was just rated

  const OrdersState({
    this.orders = const [],
    this.selectedOrder,
    this.loading = false,
    this.error,
    this.ratingSubmittedFor,
  });

  OrdersState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    bool? loading,
    String? error,
    String? ratingSubmittedFor,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      loading: loading ?? this.loading,
      error: error,
      ratingSubmittedFor: ratingSubmittedFor,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    selectedOrder,
    loading,
    error,
    ratingSubmittedFor,
  ];
}
