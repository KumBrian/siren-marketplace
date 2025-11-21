import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/repositories/i_catch_repository.dart';
import '../../../../../new_core/domain/repositories/i_offer_repository.dart';
import '../../../../../new_core/domain/repositories/i_order_repository.dart';
import '../../../../../new_core/domain/repositories/i_user_repository.dart';
import '../../../../../new_core/domain/services/order_service.dart';
import '../../../../../new_core/domain/services/rating_service.dart';
import '../../../../../new_core/domain/value_objects/rating.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderService _orderService;
  final RatingService _ratingService;
  final IOrderRepository _orderRepository;
  final ICatchRepository _catchRepository;
  final IOfferRepository _offerRepository;
  final IUserRepository _userRepository;

  OrderDetailCubit({
    OrderService? orderService,
    RatingService? ratingService,
    IOrderRepository? orderRepository,
    ICatchRepository? catchRepository,
    IOfferRepository? offerRepository,
    IUserRepository? userRepository,
  }) : _orderService = orderService ?? DI().orderService,
       _ratingService = ratingService ?? DI().ratingService,
       _orderRepository = orderRepository ?? DI().orderRepository,
       _catchRepository = catchRepository ?? DI().catchRepository,
       _offerRepository = offerRepository ?? DI().offerRepository,
       _userRepository = userRepository ?? DI().userRepository,
       super(const OrderDetailInitial());

  Future<void> loadOrderDetail(String orderId, String currentUserId) async {
    emit(const OrderDetailLoading());

    try {
      // Load order
      final order = await _orderRepository.getById(orderId);
      if (order == null) {
        emit(const OrderDetailError('Order not found'));
        return;
      }

      // Load related entities
      final catch_ = await _catchRepository.getById(order.catchId);
      final offer = await _offerRepository.getById(order.offerId);
      final counterpartyId = order.getCounterpartyId(currentUserId);
      final counterparty = await _userRepository.getById(counterpartyId);

      if (catch_ == null || offer == null || counterparty == null) {
        emit(const OrderDetailError('Related data not found'));
        return;
      }

      // Check if user can submit review
      final canSubmitReview = order.canBeReviewedBy(currentUserId);

      emit(
        OrderDetailLoaded(
          order: order,
          catch_: catch_,
          offer: offer,
          counterparty: counterparty,
          canSubmitReview: canSubmitReview,
        ),
      );
    } catch (e) {
      emit(OrderDetailError('Failed to load order detail: $e'));
    }
  }

  Future<void> completeOrder(String userId) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      final completed = await _orderService.completeOrder(
        orderId: currentState.order.id,
        userId: userId,
      );

      emit(
        currentState.copyWith(
          order: completed,
          canSubmitReview: true,
          isProcessing: false,
        ),
      );
    } catch (e) {
      emit(OrderDetailError('Failed to complete order: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> cancelOrder(String userId) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      final cancelled = await _orderService.cancelOrder(
        orderId: currentState.order.id,
        userId: userId,
      );

      emit(currentState.copyWith(order: cancelled, isProcessing: false));
    } catch (e) {
      emit(OrderDetailError('Failed to cancel order: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> submitReview({
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  }) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      await _ratingService.submitReview(
        orderId: currentState.order.id,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment,
      );

      // Reload to get updated review status
      await loadOrderDetail(currentState.order.id, reviewerId);
    } catch (e) {
      emit(OrderDetailError('Failed to submit review: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> refresh(String userId) async {
    final currentState = state;
    if (currentState is OrderDetailLoaded) {
      await loadOrderDetail(currentState.order.id, userId);
    }
  }
}
