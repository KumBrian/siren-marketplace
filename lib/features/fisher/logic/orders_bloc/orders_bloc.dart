import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/offer.dart';
// Import your models, repos, and the notifier
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;
  final OfferRepository _offerRepository; // Needed to update offer status
  final TransactionNotifier _notifier;

  StreamSubscription? _notifierSubscription;
  String? _currentUserId;

  OrdersBloc({
    required OrderRepository orderRepository,
    required OfferRepository offerRepository,
    required TransactionNotifier notifier,
  }) : _orderRepository = orderRepository,
       _offerRepository = offerRepository,
       _notifier = notifier,
       super(OrdersInitial()) {
    // --- 💡 CHANGED Notifier Setup ---
    _notifierSubscription = _notifier.updates.listen((_) {
      // Check the current state to decide what to refresh
      final currentState = state;

      if (currentState is OrdersLoaded && _currentUserId != null) {
        // If we're on the list view, refresh the list
        add(_RefreshOrders());
      } else if (currentState is OrderDetailsLoaded) {
        // If we're on the detail view, refresh just that order
        add(GetOrderById(currentState.order.id));
      }
    });

    // --- Event Handlers ---
    on<LoadOrdersForUser>(_onLoadOrdersForUser);
    on<_RefreshOrders>(_onRefreshOrders);
    on<CompleteOrder>(_onCompleteOrder);

    // --- 💡 NEW HANDLER ---
    on<GetOrderById>(_onGetOrderById);
    on<SubmitRating>(_onSubmitRating);
  }

  Future<void> _onLoadOrdersForUser(
    LoadOrdersForUser event,
    Emitter<OrdersState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(OrdersLoading());
    await _fetchAndEmitOrders(emit);
  }

  Future<void> _onRefreshOrders(
    _RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't emit loading for background refresh
    await _fetchAndEmitOrders(emit);
  }

  Future<void> _fetchAndEmitOrders(Emitter<OrdersState> emit) async {
    if (_currentUserId == null) return;

    try {
      final orders = await _orderRepository.getOrdersByUserId(_currentUserId!);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// 💡 --- NEW HANDLER IMPLEMENTATION ---
  Future<void> _onGetOrderById(
    GetOrderById event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't set _currentUserId here, as this isn't a list
    // Don't emit OrdersLoading() if we are just refreshing details
    if (state is! OrderDetailsLoaded) {
      emit(OrdersLoading());
    }

    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else {
        emit(OrdersError('Order not found'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrder event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      // 1. Get the underlying offer from the order
      final Offer offerToUpdate = event.order.offer;

      // 2. Update its status
      final completedOffer = offerToUpdate.copyWith(
        status: OfferStatus.completed, // ASSUMPTION
        waitingFor: null,
      );

      // 3. Use the OfferRepository to update the source of truth
      // This will call notifier.notify() and refresh both Blocs.
      await _offerRepository.updateOffer(completedOffer);
    } catch (e) {
      print('Error completing order: $e');
    }
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<OrdersState> emit,
  ) async {
    // Optional: Emit a loading state if needed for UX (e.g., RatingSubmitting)
    // For now, we'll try to keep the current state unless it was an error.

    // Remember the current state to return to it if the submission fails
    final previousState = state;

    try {
      // 1. Call the OrderRepository's method to handle the complex transaction
      final success = await _orderRepository.submitUserRating(
        orderId: event.orderId,
        raterId: event.raterId,
        ratedUserId: event.ratedUserId,
        ratingValue: event.ratingValue,
        message: event.message,
      );

      if (success) {
        // 2. Emit success state
        emit(RatingSubmissionSuccess(event.ratedUserId));

        // 3. Trigger a refresh to get the latest Order details (with new rating flags)
        // This ensures the UI updates to hide the rating button, etc.
        add(GetOrderById(event.orderId));
      } else {
        // 4. Handle failure (e.g., if user already rated)
        emit(
          OrdersError(
            'Failed to submit rating. User may have already been rated.',
          ),
        );
        // Optionally return to the previous state here if the error is temporary
      }
    } catch (e) {
      debugPrint('Rating submission BLoC error: $e');
      emit(
        OrdersError('An unexpected error occurred during rating submission.'),
      );
      // Return to the previous state on hard failure
      // emit(previousState);
    }
  }

  @override
  Future<void> close() {
    _notifierSubscription?.cancel();
    return super.close();
  }
}
