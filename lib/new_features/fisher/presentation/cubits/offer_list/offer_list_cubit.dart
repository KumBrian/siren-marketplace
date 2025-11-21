import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/repositories/i_offer_repository.dart';
import 'offer_list_state.dart';

class OfferListCubit extends Cubit<OfferListState> {
  final IOfferRepository _offerRepository;

  OfferListCubit({IOfferRepository? offerRepository})
    : _offerRepository = offerRepository ?? DI().offerRepository,
      super(const OfferListInitial());

  /// Load all offers for a specific fisher
  Future<void> loadOffersForFisher(String fisherId) async {
    emit(const OfferListLoading());

    try {
      final offers = await _offerRepository.getByFisherId(fisherId);
      emit(OfferListLoaded(offers: offers));
    } catch (e) {
      emit(OfferListError('Failed to load offers: $e'));
    }
  }

  /// Load all offers for a specific buyer
  Future<void> loadOffersForBuyer(String buyerId) async {
    emit(const OfferListLoading());

    try {
      final offers = await _offerRepository.getByBuyerId(buyerId);
      emit(OfferListLoaded(offers: offers));
    } catch (e) {
      emit(OfferListError('Failed to load offers: $e'));
    }
  }

  /// Refresh the current offer list for fisher
  Future<void> refreshFisher(String fisherId) async {
    await loadOffersForFisher(fisherId);
  }

  /// Refresh the current offer list for buyer
  Future<void> refreshBuyer(String buyerId) async {
    await loadOffersForBuyer(buyerId);
  }
}
