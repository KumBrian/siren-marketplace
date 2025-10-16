// lib/bloc/offer_bloc/offer_bloc.dart (Refactored)

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part "offer_event.dart";
part "offer_state.dart";

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OfferRepository repository;
  final OrderRepository _orderRepo = OrderRepository();

  OffersBloc(this.repository) : super(OffersInitial()) {
    on<LoadOffers>(_onLoadOffers);
    on<AddOffer>(_onAddOffer);
    on<UpdateOfferEvent>(_onUpdateOffer);
    on<DeleteOfferEvent>(_onDeleteOffer);
    on<LoadAllFisherOffers>(_onLoadAllFisherOffers);

    on<AcceptOfferEvent>(_onAcceptOffer);
    on<RejectOfferEvent>(_onRejectOffer);
    on<CounterOfferEvent>(_onCounterOffer);
  }

  Future<void> _onAcceptOffer(
    AcceptOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    try {
      final catchItem = event.catchItem;
      final fisher = event.fisher;

      // 1. Execute repository logic (updates offer, creates order)
      await repository.acceptOffer(
        offer: event.offer,
        catchItem: catchItem,
        fisher: fisher,
        orderRepo: _orderRepo,
      );

      // 2. Emit success state to signal UI (FisherOfferDetails) to refresh
      emit(
        OfferActionSuccess(
          "accept",
          event.offer.copyWith(
            status: OfferStatus.accepted,
          ), // Use the updated status
        ),
      );
    } catch (e) {
      emit(OfferActionFailure("accept", "Accept failed: $e"));
    }
  }

  Future<void> _onRejectOffer(
    RejectOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    try {
      await repository.rejectOffer(event.offer);

      // 1. Emit success state to signal UI to refresh
      emit(
        OfferActionSuccess(
          "reject",
          event.offer.copyWith(
            status: OfferStatus.rejected,
          ), // Use the updated status
        ),
      );
    } catch (e) {
      emit(OfferActionFailure("reject", "Reject failed: $e"));
    }
  }

  Future<void> _onCounterOffer(
    CounterOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    try {
      // ⚠️ FIX: Repository now updates the existing offer and returns it.
      final updatedOffer = await repository.counterOffer(
        previous: event.previous,
        newPrice: event.newPrice,
        newWeight: event.newWeight,
      );

      // 1. Emit success state with the updated offer.
      emit(OfferActionSuccess("counter", updatedOffer));
    } catch (e) {
      emit(OffersError("Counter failed: $e"));
    }
  }

  // --- Helper function to convert raw maps to Offer objects ---
  List<Offer> _assembleOffers(List<Map<String, dynamic>> maps) {
    return maps.map((m) => Offer.fromMap(m)).toList();
  }

  Future<void> _onLoadAllFisherOffers(
    LoadAllFisherOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    try {
      if (event.catchIds.isEmpty) {
        emit(OffersLoaded([]));
        return;
      }

      // 1. Fetch raw offer maps
      final offerMaps = await repository.getOfferMapsByCatchIds(event.catchIds);

      // 2. Assemble Offer objects
      final offers = _assembleOffers(offerMaps);

      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onLoadOffers(
    LoadOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());
    try {
      // 1. Fetch raw offer maps for a specific catch
      final offerMaps = await repository.getOfferMapsByCatch(event.catchId);

      // 2. Assemble Offer objects
      final offers = _assembleOffers(offerMaps);

      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onAddOffer(AddOffer event, Emitter<OffersState> emit) async {
    try {
      await repository.insertOffer(event.offer);

      // 1. Fetch raw maps for the updated catch
      final updatedMaps = await repository.getOfferMapsByCatch(
        event.offer.catchId,
      );

      // 2. Assemble Offer objects
      final updated = _assembleOffers(updatedMaps);

      emit(OffersLoaded(updated));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onUpdateOffer(
    UpdateOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    try {
      await repository.updateOffer(event.offer);

      // 1. Fetch raw maps for the updated catch
      final updatedMaps = await repository.getOfferMapsByCatch(
        event.offer.catchId,
      );

      // 2. Assemble Offer objects
      final updated = _assembleOffers(updatedMaps);

      emit(OffersLoaded(updated));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onDeleteOffer(
    DeleteOfferEvent event,
    Emitter<OffersState> emit,
  ) async {
    try {
      // Find the catchId to reload the correct list after deletion
      String? catchId;
      if (state is OffersLoaded) {
        final currentOffers = state as OffersLoaded;
        catchId = currentOffers.offers
            .firstWhere((o) => o.id == event.offerId)
            .catchId;
      }

      await repository.deleteOffer(event.offerId);

      if (catchId != null) {
        // 1. Fetch raw maps for the updated catch
        final updatedMaps = await repository.getOfferMapsByCatch(catchId);

        // 2. Assemble Offer objects
        final updated = _assembleOffers(updatedMaps);

        emit(OffersLoaded(updated));
      } else {
        // If catchId couldn't be found in the current state, simply reload the main list
        // Note: In a real app, this should probably reload all aggregated offers if LoadAllFisherOffers was the last call.
        emit(OffersLoaded([]));
      }
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }
}
