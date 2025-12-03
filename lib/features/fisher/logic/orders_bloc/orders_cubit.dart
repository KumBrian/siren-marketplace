import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/exceptions/domain_exception.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/services/rating_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final IOrderRepository orderRepository;
  final IOfferRepository offerRepository;
  final ICatchRepository catchRepository;
  final RatingService ratingService;

  OrdersCubit({
    required this.orderRepository,
    required this.offerRepository,
    required this.catchRepository,
    required this.ratingService,
  }) : super(const OrdersState());

  /// Load all orders for a user
  Future<void> loadForUser(String userId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await orderRepository.getByUserId(userId);
      emit(state.copyWith(loading: false, orders: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load orders: ${e.toString()}',
        ),
      );
    }
  }

  /// Load a single order by ID
  Future<void> loadById(String orderId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final order = await orderRepository.getById(orderId);

      // Update the orders list: replace if exists, append if not
      final List<Order> updatedOrders = List.from(state.orders);
      final index = updatedOrders.indexWhere((o) => o.id == order.id);

      if (index != -1) {
        updatedOrders[index] = order;
      } else {
        updatedOrders.add(order);
      }

      // Update both selectedOrder and orders list
      emit(
        state.copyWith(
          loading: false,
          selectedOrder: order,
          orders: updatedOrders,
        ),
      );
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load order: ${e.toString()}',
        ),
      );
    }
  }

  /// Complete an order
  Future<void> completeOrder(Order order) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Get the underlying offer from the order
      final Offer? offerToUpdate = await offerRepository.getById(order.offerId);

      // Update its status to completed
      final completedOffer = offerToUpdate?.copyWith(
        status: OfferStatus.completed,
        waitingFor: null,
      );

      // Update the offer repository (this will trigger transaction notifier)
      await offerRepository.update(completedOffer!);

      // Update the order status explicitly
      final completedOrder = order.markAsCompleted();
      await orderRepository.update(completedOrder);

      // Reload the order to get updated state
      await loadById(order.id);
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to complete order: ${e.toString()}',
        ),
      );
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(Order order) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // 1. Update Offer status to cancelled
      final Offer? offerToUpdate = await offerRepository.getById(order.offerId);
      final cancelledOffer = offerToUpdate?.copyWith(
        status: OfferStatus.cancelled,
        waitingFor: null,
      );
      await offerRepository.update(cancelledOffer!);

      // 2. Update Order status to cancelled
      final cancelledOrder = order.markAsCancelled();
      await orderRepository.update(cancelledOrder);

      // 3. Restore Catch weight
      final catchItem = await catchRepository.getById(order.catchId);
      if (catchItem != null) {
        final restoredCatch = catchItem.copyWith(
          availableWeight: catchItem.availableWeight + order.terms.weight,
        );
        await catchRepository.update(restoredCatch);
      }

      // Reload the order to get updated state
      await loadById(order.id);
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to cancel order: ${e.toString()}',
        ),
      );
    }
  }

  /// Submit a rating for an order
  Future<void> submitRating({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required int ratingValue,
    required String comment,
  }) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Submit the review using the rating service
      await ratingService.submitReview(
        orderId: orderId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: Rating.fromValue(ratingValue.toDouble()),
        comment: comment,
      );

      // Emit success state with the rated user ID
      emit(state.copyWith(loading: false, ratingSubmittedFor: reviewedUserId));

      // Reload the order to get updated state
      await loadById(orderId);
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to submit rating: ${e.toString()}',
        ),
      );
    }
  }

  /// Refresh orders (for background updates)
  Future<void> refresh(String userId) async {
    // Don't emit loading for background refresh
    try {
      final results = await orderRepository.getByUserId(userId);
      emit(state.copyWith(orders: results));
    } catch (e) {
      // Silently fail for background refresh
    }
  }
}
