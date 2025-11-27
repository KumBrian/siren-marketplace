import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/exceptions/business_rule_exception.dart';
import 'package:siren_marketplace/core/domain/exceptions/domain_exception.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/domain/exceptions/validation_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final IOfferRepository repository;
  final NegotiationService negotiationService;

  OffersCubit({required this.repository, required this.negotiationService})
    : super(const OffersState());

  /// Load all offers for a fisher
  Future<void> loadForFisher(String fisherId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getByFisherId(fisherId);
      emit(state.copyWith(loading: false, offers: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load offers: ${e.toString()}',
        ),
      );
    }
  }

  /// Load all offers for a buyer
  Future<void> loadForBuyer(String buyerId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getByBuyerId(buyerId);
      emit(state.copyWith(loading: false, offers: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load offers: ${e.toString()}',
        ),
      );
    }
  }

  /// Load a single offer by ID
  Future<void> loadById(String offerId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final offer = await repository.getById(offerId);

      // Update the offers list with this single offer
      // This ensures the state contains the loaded offer
      emit(
        state.copyWith(loading: false, offers: [?offer], updatedOffer: offer),
      );
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load offer: ${e.toString()}',
        ),
      );
    }
  }

  /// Load all offers for a specific catch
  Future<void> loadByCatchId(String catchId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getByCatchId(catchId);
      emit(state.copyWith(loading: false, offers: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load offers for catch: ${e.toString()}',
        ),
      );
    }
  }

  /// Accept an offer and create an order
  Future<void> acceptOffer(String offerId, UserRole role) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Get the offer to determine user ID
      final offer = await repository.getById(offerId);
      if (offer == null) {
        throw NotFoundException(entityType: 'Offer', entityId: offerId);
      }

      final userId = role == UserRole.fisher ? offer.fisherId : offer.buyerId;

      // Accept offer through negotiation service
      final order = await negotiationService.acceptOffer(
        offerId: offerId,
        userId: userId,
      );

      // Reload offers for the user
      final results = role == UserRole.fisher
          ? await repository.getByFisherId(userId)
          : await repository.getByBuyerId(userId);

      emit(
        state.copyWith(
          loading: false,
          offers: results,
          order: order,
          action: 'Accept',
        ),
      );
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on BusinessRuleException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to accept offer: ${e.toString()}',
        ),
      );
    }
  }

  /// Reject an offer
  Future<void> rejectOffer(String offerId, UserRole role) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Get the offer to determine user ID
      final offer = await repository.getById(offerId);
      if (offer == null) {
        throw NotFoundException(entityType: 'Offer', entityId: offerId);
      }

      final userId = role == UserRole.fisher ? offer.fisherId : offer.buyerId;

      // Reject offer through negotiation service
      final updatedOffer = await negotiationService.rejectOffer(
        offerId: offerId,
        userId: userId,
      );

      // Reload offers for the user
      final results = role == UserRole.fisher
          ? await repository.getByFisherId(userId)
          : await repository.getByBuyerId(userId);

      emit(
        state.copyWith(
          loading: false,
          offers: results,
          updatedOffer: updatedOffer,
          action: 'Reject',
        ),
      );
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on BusinessRuleException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to reject offer: ${e.toString()}',
        ),
      );
    }
  }

  /// Counter an offer with new terms
  Future<void> counterOffer(
    String offerId,
    UserRole role,
    OfferTerms newTerms,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Get the offer to determine user ID
      final offer = await repository.getById(offerId);
      if (offer == null) {
        throw NotFoundException(entityType: 'Offer', entityId: offerId);
      }

      final userId = role == UserRole.fisher ? offer.fisherId : offer.buyerId;

      // Counter offer through negotiation service
      final updatedOffer = await negotiationService.counterOffer(
        offerId: offerId,
        userId: userId,
        newTerms: newTerms,
      );

      // Reload offers for the user
      final results = role == UserRole.fisher
          ? await repository.getByFisherId(userId)
          : await repository.getByBuyerId(userId);

      emit(
        state.copyWith(
          loading: false,
          offers: results,
          updatedOffer: updatedOffer,
          action: 'Counter',
        ),
      );
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on ValidationException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on BusinessRuleException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to counter offer: ${e.toString()}',
        ),
      );
    }
  }

  /// Create a new offer for a catch
  Future<void> createOffer(
    String catchId,
    String buyerId,
    String fisherId,
    OfferTerms offerTerms,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      // Create offer through negotiation service
      await negotiationService.createOffer(
        catchId: catchId,
        buyerId: buyerId,
        fisherId: fisherId,
        terms: offerTerms,
      );

      // Reload offers for the buyer
      final results = await repository.getByBuyerId(buyerId);

      emit(state.copyWith(loading: false, offers: results, action: 'Create'));
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on ValidationException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on BusinessRuleException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to create offer: ${e.toString()}',
        ),
      );
    }
  }

  /// Mark an offer as viewed by the user
  Future<void> markOfferAsViewed(String offerId, UserRole role) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final offer = await repository.getById(offerId);
      if (offer == null) {
        throw NotFoundException(entityType: 'Offer', entityId: offerId);
      }

      // Update the viewed status based on role
      final updatedOffer = role == UserRole.fisher
          ? offer.copyWith(hasUpdateForFisher: false)
          : offer.copyWith(hasUpdateForBuyer: false);

      await repository.update(updatedOffer);

      // Reload offers for the user
      final userId = role == UserRole.fisher ? offer.fisherId : offer.buyerId;
      final results = role == UserRole.fisher
          ? await repository.getByFisherId(userId)
          : await repository.getByBuyerId(userId);

      emit(
        state.copyWith(
          loading: false,
          offers: results,
          updatedOffer: updatedOffer,
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
          error: 'Failed to mark offer as viewed: ${e.toString()}',
        ),
      );
    }
  }
}
