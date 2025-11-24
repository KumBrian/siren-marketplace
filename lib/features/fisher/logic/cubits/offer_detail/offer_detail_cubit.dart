import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/entities/order.dart';
import '../../../../../new_core/domain/repositories/i_catch_repository.dart';
import '../../../../../new_core/domain/repositories/i_offer_repository.dart';
import '../../../../../new_core/domain/repositories/i_order_repository.dart';
import '../../../../../new_core/domain/repositories/i_user_repository.dart';
import '../../../../../new_core/domain/services/negotiation_service.dart';
import '../../../../../new_core/domain/value_objects/offer_terms.dart';
import 'offer_detail_state.dart';

class OfferDetailCubit extends Cubit<OfferDetailState> {
  final NegotiationService _negotiationService;
  final IOfferRepository _offerRepository;
  final ICatchRepository _catchRepository;
  final IUserRepository _userRepository;
  final IOrderRepository _orderRepository;

  OfferDetailCubit({
    NegotiationService? negotiationService,
    IOfferRepository? offerRepository,
    ICatchRepository? catchRepository,
    IUserRepository? userRepository,
    IOrderRepository? orderRepository,
  }) : _negotiationService = negotiationService ?? DI().negotiationService,
       _offerRepository = offerRepository ?? DI().offerRepository,
       _catchRepository = catchRepository ?? DI().catchRepository,
       _userRepository = userRepository ?? DI().userRepository,
       _orderRepository = orderRepository ?? DI().orderRepository,
       super(const OfferDetailInitial());

  Future<void> loadOfferDetail(String offerId, String currentUserId) async {
    emit(const OfferDetailLoading());

    try {
      // Load offer
      final offer = await _offerRepository.getById(offerId);
      if (offer == null) {
        emit(const OfferDetailError('Offer not found'));
        return;
      }

      // Load related catch
      final catch_ = await _catchRepository.getById(offer.catchId);
      if (catch_ == null) {
        emit(const OfferDetailError('Related catch not found'));
        return;
      }

      // Determine counterparty (if current user is fisher, counterparty is buyer)
      final counterpartyId = currentUserId == offer.fisherId
          ? offer.buyerId
          : offer.fisherId;
      final counterparty = await _userRepository.getById(counterpartyId);
      if (counterparty == null) {
        emit(const OfferDetailError('Counterparty user not found'));
        return;
      }

      // If offer is accepted, load linked order
      Order? linkedOrder;
      if (offer.isAccepted) {
        linkedOrder = await _orderRepository.getByOfferId(offerId);
      }

      emit(
        OfferDetailLoaded(
          offer: offer,
          relatedCatch: catch_,
          counterparty: counterparty,
          linkedOrder: linkedOrder,
        ),
      );
    } catch (e) {
      emit(OfferDetailError('Failed to load offer detail: $e'));
    }
  }

  Future<void> acceptOffer(String userId) async {
    final currentState = state;
    if (currentState is! OfferDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      final order = await _negotiationService.acceptOffer(
        offerId: currentState.offer.id,
        userId: userId,
      );

      // Reload to get updated offer and order
      await loadOfferDetail(currentState.offer.id, userId);
    } catch (e) {
      emit(OfferDetailError('Failed to accept offer: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> rejectOffer(String userId) async {
    final currentState = state;
    if (currentState is! OfferDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      final rejected = await _negotiationService.rejectOffer(
        offerId: currentState.offer.id,
        userId: userId,
      );

      emit(currentState.copyWith(offer: rejected, isProcessing: false));
    } catch (e) {
      emit(OfferDetailError('Failed to reject offer: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> counterOffer({
    required String userId,
    required OfferTerms newTerms,
  }) async {
    final currentState = state;
    if (currentState is! OfferDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true));

    try {
      final countered = await _negotiationService.counterOffer(
        offerId: currentState.offer.id,
        userId: userId,
        newTerms: newTerms,
      );

      emit(currentState.copyWith(offer: countered, isProcessing: false));
    } catch (e) {
      emit(OfferDetailError('Failed to counter offer: $e'));
      emit(currentState.copyWith(isProcessing: false));
    }
  }

  Future<void> markAsViewed(String userId) async {
    final currentState = state;
    if (currentState is! OfferDetailLoaded) return;

    // Only mark if it's the user's turn
    if (!currentState.offer.isUsersTurn(userId)) return;

    try {
      // This would update hasUpdateForFisher or hasUpdateForBuyer
      // For now, we're not tracking this in the domain model
      // You can add this logic if needed
    } catch (e) {
      // Silent fail - not critical
    }
  }

  Future<void> refresh(String userId) async {
    final currentState = state;
    if (currentState is OfferDetailLoaded) {
      await loadOfferDetail(currentState.offer.id, userId);
    }
  }
}
