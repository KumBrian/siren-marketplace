import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository orderRepository;
  final OfferRepository offerRepository;
  final UserRepository userRepository;

  OrdersBloc(this.orderRepository, this.offerRepository, this.userRepository)
    : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadAllFisherOrders>(_onLoadAllFisherOrders);
    on<AddOrder>(_onAddOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<GetOrderByOfferId>(_onGetOrderByOfferId);
  }

  // --- Helper function to assemble the full Order model ---
  Future<Order?> _assembleOrder(Map<String, dynamic> orderMap) async {
    // Defensive casts
    final offerId = orderMap['offer_id'] as String?;
    final fisherId = orderMap['fisher_id'] as String?;

    if (offerId == null || fisherId == null) {
      // Log for traceability
      print('[OrdersBloc] Missing offer_id or fisher_id in orderMap');
      return null;
    }

    // 1. Fetch corresponding Offer map and assemble Offer object
    final offerMap = await offerRepository.getOfferMapById(offerId);
    if (offerMap == null) {
      print('[OrdersBloc] Offer not found for ID $offerId');
      return null;
    }
    final linkedOffer = Offer.fromMap(offerMap);

    // 2. Fetch the Fisher map and assemble Fisher object
    final fisherMap = await userRepository.getUserMapById(fisherId);
    if (fisherMap == null) {
      print('[OrdersBloc] Fisher not found for ID $fisherId');
      return null;
    }
    final linkedFisher = Fisher.fromMap(fisherMap);

    // 3. Use the factory constructor to build the Order
    return Order.fromMap(
      m: orderMap,
      linkedOffer: linkedOffer,
      linkedFisher: linkedFisher,
    );
  }

  Future<void> _onLoadAllFisherOrders(
    LoadAllFisherOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orderMaps = await orderRepository.getOrderMapsByUserId(
        event.userId,
      );

      final orders = <Order>[];
      for (final map in orderMaps) {
        final order = await _assembleOrder(map);
        if (order != null) orders.add(order);
      }

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orderMaps = await orderRepository.getAllOrderMaps();

      final orders = <Order>[];
      for (final map in orderMaps) {
        final order = await _assembleOrder(map);
        if (order != null) orders.add(order);
      }

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrdersState> emit) async {
    try {
      await orderRepository.insertOrder(event.order);
      await _onLoadOrders(LoadOrders(), emit);
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await orderRepository.deleteOrder(event.orderId);
      await _onLoadOrders(LoadOrders(), emit);
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onGetOrderByOfferId(
    GetOrderByOfferId event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final orderMap = await orderRepository.getOrderMapByOfferId(
        event.offerId,
      );

      if (orderMap == null) {
        emit(OrdersError('Order not found for offer ID: ${event.offerId}'));
        return;
      }

      final order = await _assembleOrder(orderMap);
      if (order != null) {
        emit(SingleOrderLoaded(order));
      } else {
        emit(OrdersError('Incomplete Order data: missing Offer/Fisher.'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
