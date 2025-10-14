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
    // 🆕 Register the new event handler
    on<LoadAllFisherOrders>(_onLoadAllFisherOrders);
    on<AddOrder>(_onAddOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<GetOrderByOfferId>(_onGetOrderByOfferId);
  }

  // --- Helper function to assemble the full Order model ---
  Future<Order?> _assembleOrder(Map<String, dynamic> orderMap) async {
    final offerId = orderMap['offer_id'] as String;
    final fisherId = orderMap['fisher_id'] as String;

    // 1. Fetch the corresponding Offer map and assemble the Offer object
    final offerMap = await offerRepository.getOfferMapById(offerId);
    if (offerMap == null) return null;
    final linkedOffer = Offer.fromMap(offerMap);

    // 2. Fetch the Fisher map and assemble the Fisher object
    final fisherMap = await userRepository.getUserMapById(fisherId);
    if (fisherMap == null) return null;
    final linkedFisher = Fisher.fromMap(fisherMap);

    // 3. Use the required factory to build the full Order object
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

      final List<Order> orders = [];
      for (final map in orderMaps) {
        final order = await _assembleOrder(map);
        if (order != null) {
          orders.add(order);
        }
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
      // 1. Fetch ALL raw order maps (Used for general global view/initial seeding check)
      final orderMaps = await orderRepository.getAllOrderMaps();

      // 2. Assemble the full Order objects, filtering out any that can't be assembled
      final List<Order> orders = [];
      for (final map in orderMaps) {
        final order = await _assembleOrder(map);
        if (order != null) {
          orders.add(order);
        }
      }

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrdersState> emit) async {
    try {
      await orderRepository.insertOrder(event.order);
      // NOTE: You may want to reload using the specific LoadAllFisherOrders
      // event here if the bloc is currently displaying user-specific orders.
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
      // Reload the list to reflect the deletion
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
      // 1. Fetch raw order map by offer ID
      final orderMap = await orderRepository.getOrderMapByOfferId(
        event.offerId,
      );

      if (orderMap == null) {
        emit(OrdersError('Order not found for offer ID: ${event.offerId}'));
        return;
      }

      // 2. Assemble the full Order object
      final order = await _assembleOrder(orderMap);

      if (order != null) {
        emit(SingleOrderLoaded(order));
      } else {
        // Handle case where Order map exists but linked Offer/Fisher is missing
        emit(
          OrdersError(
            'Linked dependencies (Offer/Fisher) not found for Order.',
          ),
        );
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
