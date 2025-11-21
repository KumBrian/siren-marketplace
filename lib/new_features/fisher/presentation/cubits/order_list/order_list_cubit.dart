import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/new_core/di/injection.dart';
import 'package:siren_marketplace/new_core/domain/repositories/i_order_repository.dart';
import 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  final IOrderRepository _orderRepository;

  OrderListCubit({IOrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? DI().orderRepository,
      super(const OrderListInitial());

  /// Load all orders for a specific buyer
  Future<void> loadOrdersForBuyer(String buyerId) async {
    emit(const OrderListLoading());

    try {
      final orders = await _orderRepository.getByBuyerId(buyerId);
      emit(OrderListLoaded(orders: orders));
    } catch (e) {
      emit(OrderListError('Failed to load orders: ${e.toString()}'));
    }
  }

  /// Load all orders for a specific fisher
  Future<void> loadOrdersForFisher(String fisherId) async {
    emit(const OrderListLoading());

    try {
      final orders = await _orderRepository.getByFisherId(fisherId);
      emit(OrderListLoaded(orders: orders));
    } catch (e) {
      emit(OrderListError('Failed to load orders: ${e.toString()}'));
    }
  }

  /// Refresh orders for buyer
  Future<void> refreshBuyer(String buyerId) async {
    await loadOrdersForBuyer(buyerId);
  }

  /// Refresh orders for fisher
  Future<void> refreshFisher(String fisherId) async {
    await loadOrdersForFisher(fisherId);
  }
}
