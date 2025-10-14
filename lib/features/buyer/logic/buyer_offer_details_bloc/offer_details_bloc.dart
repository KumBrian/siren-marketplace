import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';

part 'offer_details_event.dart';
part 'offer_details_state.dart';

// This definition must also use List<Object?>
// NOTE: I am providing the BLoC file here for completeness,
// assuming you defined the OfferDetailsLoaded class in offer_details_state.dart
// as shown in the previous response.

class OfferDetailsBloc extends Bloc<OfferDetailsEvent, OfferDetailsState> {
  final OfferRepository offerRepository;
  final CatchRepository catchRepository;
  final UserRepository userRepository;

  OfferDetailsBloc(
    this.offerRepository,
    this.catchRepository,
    this.userRepository,
  ) : super(OfferDetailsInitial()) {
    on<LoadOfferDetails>(_onLoadOfferDetails);
  }

  Future<void> _onLoadOfferDetails(
    LoadOfferDetails event,
    Emitter<OfferDetailsState> emit,
  ) async {
    emit(OfferDetailsLoading());
    try {
      // 1. Fetch the raw Offer map and convert it to a model
      final offerMap = await offerRepository.getOfferMapById(event.offerId);

      if (offerMap == null) {
        emit(const OfferDetailsError("Offer not found."));
        return;
      }
      final Offer offer = Offer.fromMap(offerMap);

      // 2. Load dependencies using IDs from the Offer
      final String catchId = offer.catchId;
      final String fisherId = offer.fisherId;

      // 2a. Fetch Catch details
      final catchMap = await catchRepository.getCatchMapById(catchId);
      if (catchMap == null) {
        emit(const OfferDetailsError("Linked Catch not found."));
        return;
      }
      final Catch catchItem = Catch.fromMap(catchMap);

      // 2b. Fetch Fisher details
      final fisherMap = await userRepository.getUserMapById(fisherId);
      if (fisherMap == null) {
        emit(const OfferDetailsError("Linked Fisher profile not found."));
        return;
      }
      final Fisher fisher = Fisher.fromMap(fisherMap);

      // 3. Emit the final assembled state
      // Ensure OfferDetailsLoaded is defined in offer_details_state.dart with List<Object?>
      emit(OfferDetailsLoaded(offer, catchItem, fisher));
    } catch (e) {
      emit(OfferDetailsError('Failed to load offer details: ${e.toString()}'));
    }
  }
}
