// lib/bloc/offer_bloc/offer_bloc.dart (Refactored)

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';

part "offer_event.dart";
part "offer_state.dart";

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OfferRepository repository;

  OffersBloc(this.repository) : super(OffersInitial()) {
    on<LoadOffers>(_onLoadOffers);
    on<AddOffer>(_onAddOffer);
    on<UpdateOfferEvent>(_onUpdateOffer);
    on<DeleteOfferEvent>(_onDeleteOffer);
    on<LoadAllFisherOffers>(_onLoadAllFisherOffers);
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
