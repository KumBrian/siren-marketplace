import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart'; // Import CatchRepository
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository orderRepository;
  final OfferRepository offerRepository;
  final UserRepository userRepository;
  final CatchRepository catchRepository; // Add CatchRepository

  OrdersBloc(
    this.orderRepository,
    this.offerRepository,
    this.userRepository,
    this.catchRepository, // Inject CatchRepository
  ) : super(OrdersInitial()) {
    print('OrdersBloc created');
    on<LoadOrders>(_onLoadOrders);
    on<LoadAllFisherOrders>(_onLoadAllFisherOrders);
    on<AddOrder>(_onAddOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<GetOrderByOfferId>(_onGetOrderByOfferId);
    // on<MarkOrderAsCompleted>(_onMarkOrderAsCompleted); // New handler

    // Previous Fix: Removed generic OrdersLoading()
    on<GetOrderById>((event, emit) async {
      try {
        final order = await orderRepository.getOrderById(event.orderId);

        if (order != null) {
          emit(SingleOrderLoaded(order));
        } else {
          emit(OrdersError('Order with ID ${event.orderId} not found.'));
        }
      } catch (e) {
        emit(OrdersError('Failed to fetch order: $e'));
      }
    });

    on<UpdateOrder>((event, emit) {
      if (state is OrdersLoaded) {
        final current = (state as OrdersLoaded).orders;
        final updatedList = current.map((order) {
          return order.id == event.updatedOrder.id ? event.updatedOrder : order;
        }).toList();

        emit(OrdersLoaded(updatedList));
      }
    });
  }

  Future<Order?> _assembleOrder(Map<String, dynamic> orderMap) async {
    final offerId = orderMap['offer_id'] as String?;
    final fisherId = orderMap['fisher_id'] as String?;

    if (offerId == null || fisherId == null) {
      return null;
    }

    // These two operations run sequentially within this function,
    // but the calls to _assembleOrder() will run in parallel below.
    final offerMap = await offerRepository
        .getOfferMapById(offerId)
        .timeout(const Duration(seconds: 10));

    if (offerMap == null) {
      return null;
    }
    final linkedOffer = Offer.fromMap(offerMap);

    final fisherMap = await userRepository
        .getUserMapById(fisherId)
        .timeout(const Duration(seconds: 10));

    if (fisherMap == null) {
      return null;
    }
    final linkedFisher = Fisher.fromMap(fisherMap);

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
    if (state is OrdersLoaded) {
      return;
    }

    if (state is OrdersInitial || state is OrdersError) {
      emit(OrdersLoading());
    }

    try {
      final orderMaps = await orderRepository.getOrderMapsByUserId(
        event.userId,
      );

      // 🚀 BOTTLENECK FIX: Use Future.wait to execute all _assembleOrder lookups concurrently.
      final orderFutures = orderMaps.map((map) {
        return _assembleOrder(map).timeout(const Duration(seconds: 20));
      }).toList();

      final orders = (await Future.wait(
        orderFutures,
      )).whereType<Order>().toList();

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersLoaded) {
      return;
    }

    if (state is OrdersInitial || state is OrdersError) {
      emit(OrdersLoading());
    }

    try {
      final orderMaps = await orderRepository.getAllOrderMaps();

      // 🚀 BOTTLENECK FIX: Use Future.wait to execute all _assembleOrder lookups concurrently.
      final orderFutures = orderMaps.map((map) {
        return _assembleOrder(map).timeout(const Duration(seconds: 20));
      }).toList();

      final orders = (await Future.wait(
        orderFutures,
      )).whereType<Order>().toList();

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrdersState> emit) async {
    try {
      await orderRepository.insertOrder(event.order);

      // Perform silent refresh
      final orderMaps = await orderRepository.getAllOrderMaps();

      // 🚀 BOTTLENECK FIX: Use Future.wait for silent refresh after AddOrder
      final orderFutures = orderMaps.map((map) {
        return _assembleOrder(map).timeout(const Duration(seconds: 20));
      }).toList();

      final orders = (await Future.wait(
        orderFutures,
      )).whereType<Order>().toList();

      emit(OrdersLoaded(orders));
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

      // Perform silent refresh
      final orderMaps = await orderRepository.getAllOrderMaps();

      // 🚀 BOTTLENECK FIX: Use Future.wait for silent refresh after DeleteOrder
      final orderFutures = orderMaps.map((map) {
        return _assembleOrder(map).timeout(const Duration(seconds: 20));
      }).toList();

      final orders = (await Future.wait(
        orderFutures,
      )).whereType<Order>().toList();

      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onGetOrderByOfferId(
    GetOrderByOfferId event,
    Emitter<OrdersState> emit,
  ) async {
    // Note: Single item loading is not significantly bottlenecked by N+1,
    // but the sequential assembly within _assembleOrder still applies.
    emit(OrdersLoading());

    try {
      final orderMap = await orderRepository
          .getOrderMapByOfferId(event.offerId)
          .timeout(const Duration(seconds: 15));

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
      emit(OrdersError('Failed to load order details: ${e.toString()}'));
    }
  }

  // Future<void> _onMarkOrderAsCompleted(
  //   MarkOrderAsCompleted event,
  //   Emitter<OrdersState> emit,
  // ) async {
  //   emit(OrdersLoading());
  //   try {
  //     final order = event.order;
  //
  //     // 1. Update Offer status to completed
  //     final updatedOffer = order.offer.copyWith(status: OfferStatus.completed);
  //     await offerRepository.updateOffer(updatedOffer);
  //
  //     // 2. Update Catch available weight
  //     final double acceptedWeight = order.offer.weight;
  //     final originalCatch = await catchRepository.getCatchById(
  //       order.offer.catchId,
  //     );
  //
  //     if (originalCatch == null) {
  //       throw Exception('Original catch not found for order completion.');
  //     }
  //
  //     final newAvailableWeight = originalCatch.availableWeight - acceptedWeight;
  //     final updatedCatch = originalCatch.copyWith(
  //       availableWeight: newAvailableWeight > 0 ? newAvailableWeight : 0,
  //       status: newAvailableWeight <= 0
  //           ? CatchStatus.sold
  //           : originalCatch.status, // Mark as sold if weight is 0 or less
  //     );
  //     await catchRepository.updateCatch(updatedCatch);
  //
  //     // 3. Re-create catchSnapshotJson from the updatedCatch
  //     // Ensure the snapshot includes the accepted transaction details
  //     final Map<String, dynamic> updatedCatchSnapshotMap = updatedCatch.toMap()
  //       ..['accepted_weight'] = acceptedWeight
  //       ..['accepted_price_per_kg'] = order.offer.pricePerKg
  //       ..['accepted_price'] = order.offer.price;
  //
  //     final updatedCatchSnapshotJson = jsonEncode(updatedCatchSnapshotMap);
  //
  //     // 4. Update Order with the updated Offer and new catchSnapshotJson
  //     final fullyUpdatedOrder = order.copyWith(
  //       offer: updatedOffer,
  //       catchSnapshotJson: updatedCatchSnapshotJson,
  //       catchModel: Catch.fromMap(updatedCatchSnapshotMap),
  //       // Update catchModel as well
  //       dateUpdated: DateTime.now().toIso8601String(), // Update dateUpdated
  //     );
  //     await orderRepository.updateOrder(fullyUpdatedOrder);
  //
  //     // After all updates, emit the single updated order to refresh the UI
  //     emit(SingleOrderLoaded(fullyUpdatedOrder));
  //   } catch (e) {
  //     emit(OrdersError('Failed to mark order as completed: ${e.toString()}'));
  //   }
  // }
}
