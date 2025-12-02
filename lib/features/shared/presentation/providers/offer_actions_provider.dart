import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/features/shared/presentation/providers/shared_offer_details_provider.dart';

class OfferActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final Order? createdOrder; // For navigation after accept

  const OfferActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.createdOrder,
  });

  OfferActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    Order? createdOrder,
  }) {
    return OfferActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable update
      successMessage: successMessage, // Nullable update
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }
}

class OfferActionsNotifier extends StateNotifier<OfferActionState> {
  final Ref ref;
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;
  final NegotiationService _negotiationService;

  OfferActionsNotifier(this.ref)
    : _offerRepository = sl<IOfferRepository>(),
      _orderRepository = sl<IOrderRepository>(),
      _negotiationService = sl<NegotiationService>(),
      super(const OfferActionState());

  Future<void> acceptOffer(String offerId, UserRole role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _offerRepository.acceptOffer(offerId, role);

      // Fetch the created order
      final order = await _orderRepository.getByOfferId(offerId);

      // Get the offer to find catchId for invalidation
      final offer = await _offerRepository.getById(offerId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Offer accepted successfully!',
        createdOrder: order,
      );

      // Invalidate both offer detail and offer list providers
      ref.invalidate(sharedOfferDetailsProvider(offerId));
      if (offer != null) {
        ref.invalidate(offersByCatchProvider(offer.catchId));
      }

      // Invalidate role-specific providers to update UI
      if (role == UserRole.fisher) {
        await ref.refresh(fisherOffersProvider.future);
      } else {
        await ref.refresh(buyerOffersProvider.future);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> rejectOffer(String offerId, UserRole role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get the offer to find catchId for invalidation
      final offer = await _offerRepository.getById(offerId);

      await _offerRepository.rejectOffer(offerId, role);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Offer rejected.',
      );

      // Invalidate both offer detail and offer list providers
      ref.invalidate(sharedOfferDetailsProvider(offerId));
      if (offer != null) {
        ref.invalidate(offersByCatchProvider(offer.catchId));
      }

      // Invalidate role-specific providers to update UI
      if (role == UserRole.fisher) {
        await ref.refresh(fisherOffersProvider.future);
      } else {
        await ref.refresh(buyerOffersProvider.future);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> counterOffer(
    String offerId,
    UserRole role,
    OfferTerms terms,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get the offer to find catchId for invalidation
      final offer = await _offerRepository.getById(offerId);

      await _offerRepository.counterOffer(offerId, role, terms);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Counter-offer sent!',
      );

      // Invalidate both offer detail and offer list providers
      ref.invalidate(sharedOfferDetailsProvider(offerId));
      if (offer != null) {
        ref.invalidate(offersByCatchProvider(offer.catchId));
      }

      // Invalidate role-specific providers to update UI
      if (role == UserRole.fisher) {
        await ref.refresh(fisherOffersProvider.future);
      } else {
        await ref.refresh(buyerOffersProvider.future);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsViewed(String offerId, UserRole role) async {
    try {
      // Get the offer to find catchId for invalidation
      final offer = await _offerRepository.getById(offerId);

      await _offerRepository.markAsViewed(offerId, role);

      // Invalidate both offer detail and offer list providers
      ref.invalidate(sharedOfferDetailsProvider(offerId));
      if (offer != null) {
        ref.invalidate(offersByCatchProvider(offer.catchId));
      }

      // Force refresh role-specific offer lists to update badges/counts immediately
      if (role == UserRole.fisher) {
        await ref.refresh(fisherOffersProvider.future);
      } else {
        await ref.refresh(buyerOffersProvider.future);
      }
    } catch (e) {
      // Silent fail for view marking
    }
  }

  Future<void> createOffer(
    String catchId,
    String buyerId,
    String fisherId,
    OfferTerms terms,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _negotiationService.createOffer(
        catchId: catchId,
        buyerId: buyerId,
        fisherId: fisherId,
        terms: terms,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Offer sent successfully!',
      );

      // Invalidate offers list for this catch
      ref.invalidate(offersByCatchProvider(catchId));
      // Invalidate buyer offers list
      ref.invalidate(buyerOffersProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const OfferActionState();
  }
}

final offerActionsProvider =
    StateNotifierProvider.autoDispose<OfferActionsNotifier, OfferActionState>((
      ref,
    ) {
      return OfferActionsNotifier(ref);
    });
