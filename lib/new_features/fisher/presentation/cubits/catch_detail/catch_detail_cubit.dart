import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/enums/offer_status.dart';
import '../../../../../new_core/domain/repositories/i_catch_repository.dart';
import '../../../../../new_core/domain/repositories/i_offer_repository.dart';
import '../../../../../new_core/domain/services/marketplace_service.dart';
import '../../../../../new_core/domain/value_objects/price_per_kg.dart';
import '../../../../../new_core/domain/value_objects/weight.dart';
import 'catch_detail_state.dart';

class CatchDetailCubit extends Cubit<CatchDetailState> {
  final ICatchRepository _catchRepository;
  final IOfferRepository _offerRepository;
  final MarketplaceService _marketplaceService;

  CatchDetailCubit({
    ICatchRepository? catchRepository,
    IOfferRepository? offerRepository,
    MarketplaceService? marketplaceService,
  }) : _catchRepository = catchRepository ?? DI().catchRepository,
       _offerRepository = offerRepository ?? DI().offerRepository,
       _marketplaceService = marketplaceService ?? DI().marketplaceService,
       super(const CatchDetailInitial());

  Future<void> loadCatchDetail(String catchId) async {
    emit(const CatchDetailLoading());

    try {
      final catch_ = await _catchRepository.getById(catchId);
      if (catch_ == null) {
        emit(const CatchDetailError('Catch not found'));
        return;
      }

      final offers = await _offerRepository.getByCatchId(catchId);

      emit(CatchDetailLoaded(catch_: catch_, offers: offers));
    } catch (e) {
      emit(CatchDetailError('Failed to load catch detail: $e'));
    }
  }

  Future<void> updatePricing({
    required String fisherId,
    required PricePerKg newPricePerKg,
  }) async {
    final currentState = state;
    if (currentState is! CatchDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    try {
      final updated = await _marketplaceService.updateCatchPricing(
        catchId: currentState.catch_.id,
        fisherId: fisherId,
        newPricePerKg: newPricePerKg,
      );

      emit(currentState.copyWith(catch_: updated, isUpdating: false));
    } catch (e) {
      emit(CatchDetailError('Failed to update pricing: $e'));
      emit(currentState.copyWith(isUpdating: false));
    }
  }

  Future<void> updateWeight({required Weight newWeight}) async {
    final currentState = state;
    if (currentState is! CatchDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    try {
      final updated = currentState.catch_.copyWith(availableWeight: newWeight);

      await _catchRepository.update(updated);

      emit(currentState.copyWith(catch_: updated, isUpdating: false));
    } catch (e) {
      emit(CatchDetailError('Failed to update weight: $e'));
      emit(currentState.copyWith(isUpdating: false));
    }
  }

  Future<void> deleteCatch(String fisherId) async {
    final currentState = state;
    if (currentState is! CatchDetailLoaded) return;

    try {
      await _marketplaceService.removeCatch(currentState.catch_.id, fisherId);

      // Navigate back will be handled by UI
    } catch (e) {
      emit(CatchDetailError('Failed to delete catch: $e'));
      emit(currentState);
    }
  }

  void filterOffers(OfferStatus? status) {
    final currentState = state;
    if (currentState is! CatchDetailLoaded) return;

    if (status == null) {
      // Clear filter - reload all offers
      loadCatchDetail(currentState.catch_.id);
    } else {
      // Filter in memory
      final allOffers = currentState.offers;
      // Note: This assumes we keep all offers in state
      // For production, you might want to reload from repo with filter
      emit(currentState.copyWith(filterStatus: status));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is CatchDetailLoaded) {
      await loadCatchDetail(currentState.catch_.id);
    }
  }
}
