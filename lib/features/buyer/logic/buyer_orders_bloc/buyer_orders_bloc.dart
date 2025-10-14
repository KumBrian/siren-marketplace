import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/buyer/data/buyer_repository.dart';

part 'buyer_orders_event.dart';
part 'buyer_orders_state.dart';

class BuyerOrdersBloc extends Bloc<BuyerOrdersEvent, BuyerOrdersState> {
  final BuyerRepository repository;

  BuyerOrdersBloc(this.repository) : super(BuyerOrdersInitial()) {
    on<LoadBuyerOrders>(_onLoadBuyerOrders);
  }

  Future<void> _onLoadBuyerOrders(
    LoadBuyerOrders event,
    Emitter<BuyerOrdersState> emit,
  ) async {
    emit(BuyerOrdersLoading());
    try {
      final orders = await repository.getOrdersByBuyerId(event.buyerId);
      emit(BuyerOrdersLoaded(orders));
    } catch (e) {
      emit(BuyerOrdersError("Failed to load orders: $e"));
    }
  }
}
