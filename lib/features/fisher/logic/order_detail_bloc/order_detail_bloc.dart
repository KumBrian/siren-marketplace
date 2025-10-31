import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderRepository orderRepository;
  final CatchRepository catchRepository;
  final UserRepository userRepository;
  final OfferRepository offerRepository;

  OrderDetailBloc(
    this.orderRepository,
    this.catchRepository,
    this.userRepository,
    this.offerRepository,
  ) : super(OrderDetailInitial()) {
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<ClearOrderDetails>(_onClearOrderDetails);
    on<MarkOrderAsCompleted>(_onMarkOrderAsCompleted);
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailLoading());
    try {
      final order = await orderRepository.getOrderById(event.orderId);

      if (order == null) {
        emit(const OrderDetailError('Order not found'));
        return;
      }

      final catchSnapshot = await catchRepository.getCatchById(
        order.offer.catchId,
      );
      final buyerMap = await userRepository.getUserMapById(order.buyerId);
      final buyer = AppUser.fromMap(buyerMap!);

      emit(
        OrderDetailLoaded(
          order: order,
          catchSnapshot: catchSnapshot!,
          buyer: buyer,
        ),
      );
    } catch (e) {
      emit(OrderDetailError(e.toString()));
    }
  }

  Future<void> _onMarkOrderAsCompleted(
    MarkOrderAsCompleted event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailLoading());
    try {
      final order = event.order;

      // 1. Update Offer status to completed
      final updatedOffer = order.offer.copyWith(status: OfferStatus.completed);
      await offerRepository.updateOffer(updatedOffer);

      // 2. Update Catch available weight
      final double acceptedWeight = order.offer.weight;
      final originalCatch = await catchRepository.getCatchById(
        order.offer.catchId,
      );

      if (originalCatch == null) {
        throw Exception('Original catch not found for order completion.');
      }

      final newAvailableWeight = originalCatch.availableWeight - acceptedWeight;
      final updatedCatch = originalCatch.copyWith(
        availableWeight: newAvailableWeight > 0 ? newAvailableWeight : 0,
        status: newAvailableWeight <= 0
            ? CatchStatus.sold
            : originalCatch.status, // Mark as sold if weight is 0 or less
      );
      await catchRepository.updateCatch(updatedCatch);

      // 3. Re-create catchSnapshotJson from the updatedCatch
      // Ensure the snapshot includes the accepted transaction details
      final Map<String, dynamic> updatedCatchSnapshotMap = updatedCatch.toMap()
        ..['accepted_weight'] = acceptedWeight
        ..['accepted_price_per_kg'] = order.offer.pricePerKg
        ..['accepted_price'] = order.offer.price;

      final updatedCatchSnapshotJson = jsonEncode(updatedCatchSnapshotMap);

      // 4. Update Order with the updated Offer and new catchSnapshotJson
      final fullyUpdatedOrder = order.copyWith(
        offer: updatedOffer,
        catchSnapshotJson: updatedCatchSnapshotJson,
        catchModel: Catch.fromMap(updatedCatchSnapshotMap),
        // Update catchModel as well
        dateUpdated: DateTime.now().toIso8601String(), // Update dateUpdated
      );
      await orderRepository.updateOrder(fullyUpdatedOrder);

      final buyerMap = await userRepository.getUserMapById(order.buyerId);
      final buyer = AppUser.fromMap(buyerMap!);

      emit(OrderMarkedCompleted(fullyUpdatedOrder));

      // After all updates, emit the single updated order to refresh the UI
      emit(
        OrderDetailLoaded(
          order: fullyUpdatedOrder,
          catchSnapshot: updatedCatch,
          buyer: buyer,
        ),
      );
    } catch (e) {
      emit(
        OrderDetailError('Failed to mark order as completed: ${e.toString()}'),
      );
    }
  }

  void _onClearOrderDetails(
    ClearOrderDetails event,
    Emitter<OrderDetailState> emit,
  ) {
    emit(OrderDetailInitial());
  }
}
