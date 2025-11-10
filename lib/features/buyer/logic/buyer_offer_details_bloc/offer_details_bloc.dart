import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';
import 'package:uuid/uuid.dart';

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
  final OrderRepository orderRepository;

  final Uuid _uuid = const Uuid();

  OfferDetailsBloc(
    this.offerRepository,
    this.catchRepository,
    this.userRepository,
    this.orderRepository,
  ) : super(OfferDetailsInitial()) {
    on<LoadOfferDetails>(_onLoadOfferDetails);
    on<AcceptOffer>(_onAcceptOffer);
    on<SendCounterOffer>(_onSendCounterOffer);
    on<MarkOfferAsViewed>(_onMarkOfferAsViewed);
  }

  Future<void> _onMarkOfferAsViewed(
    MarkOfferAsViewed event,
    Emitter<OfferDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OfferDetailsLoaded) return;

    final offer = currentState.offer;

    // Determine which flag needs clearing and check if it's already cleared
    final isBuyer = event.viewingRole == Role.buyer;
    final needsUpdate = isBuyer
        ? offer.hasUpdateForBuyer
        : offer.hasUpdateForFisher;

    if (!needsUpdate) return; // Already cleared, no need for repository call

    try {
      // 1. Create the updated offer model, clearing only the viewer's flag
      final viewedOffer = offer.copyWith(
        hasUpdateForBuyer: isBuyer ? false : null,
        hasUpdateForFisher: isBuyer ? null : false,
      );

      // 2. Persist the change to the database
      await offerRepository.updateOffer(viewedOffer);

      // 3. Emit the new state to update the UI
      emit(
        currentState.copyWith(
          offer: viewedOffer,
          // No successMessageId needed here as it's a passive update
        ),
      );
    } catch (e) {
      // Log error but don't stop the flow; viewing an offer is critical
      print('Error marking offer as viewed: ${e.toString()}');
      // We don't change the state as a failure to mark as viewed is not fatal to the UI
    }
  }

  Future<void> _onLoadOfferDetails(
    LoadOfferDetails event,
    Emitter<OfferDetailsState> emit,
  ) async {
    emit(OfferDetailsLoading());
    try {
      final offerMap = await offerRepository.getOfferMapById(event.offerId);
      if (offerMap == null) {
        emit(const OfferDetailsError("Offer not found."));
        return;
      }
      final Offer offer = Offer.fromMap(offerMap);

      final String catchId = offer.catchId;
      final String fisherId = offer.fisherId;

      final catchMap = await catchRepository.getCatchMapById(catchId);
      if (catchMap == null) {
        emit(const OfferDetailsError("Linked Catch not found."));
        return;
      }
      final Catch catchItem = Catch.fromMap(catchMap);

      final fisherMap = await userRepository.getUserMapById(fisherId);
      if (fisherMap == null) {
        emit(const OfferDetailsError("Linked Fisher profile not found."));
        return;
      }
      final Fisher fisher = Fisher.fromMap(fisherMap);

      emit(OfferDetailsLoaded(offer, catchItem, null, fisher));
    } catch (e) {
      emit(OfferDetailsError('Failed to load offer details: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptOffer(
    AcceptOffer event,
    Emitter<OfferDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OfferDetailsLoaded) return;

    // 🔑 Optional: Emit a temporary loading state to show progress
    // emit(OfferDetailsLoading());

    try {
      // 1. Perform the repository action.
      //    We assume it returns the newly updated Offer (status=accepted).
      final (updatedOffer, newOrderId) = await offerRepository.acceptOffer(
        offer: event.offer,
        catchItem: event.catchItem,
        fisher: event.fisher,
        orderRepo: orderRepository,
      );

      // 2. Emit the new state with the accepted offer and the success ID
      emit(
        currentState.copyWith(
          offer: updatedOffer,
          newOrderId: newOrderId,
          successMessageId: _uuid.v4(), // 🔑 Unique ID for one-time success
        ),
      );
    } catch (e) {
      // 3. Handle failure
      // Reload the previous state to maintain UI continuity
      emit(OfferDetailsError('Failed to accept offer: ${e.toString()}'));
      // Emit the previous loaded state to ensure the UI is not stuck on error
      emit(currentState);
    }
  }

  // 🆕 HANDLER: Send Counter Offer
  Future<void> _onSendCounterOffer(
    SendCounterOffer event,
    Emitter<OfferDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OfferDetailsLoaded) return;

    // You would typically emit a loading state here
    // emit(OfferDetailsLoading());

    try {
      // 1. Perform the repository action (Assuming it returns the new/updated Offer)
      final newOrCounteredOffer = await offerRepository.counterOffer(
        previous: event.offer,
        newWeight: event.newWeight,
        newPrice: event.newPrice,
        role: event.role,
      );

      // 2. Emit the new state with the updated offer and the success ID
      emit(
        currentState.copyWith(
          offer: newOrCounteredOffer,
          successMessageId: _uuid.v4(), // 🔑 Unique ID for one-time success
        ),
      );
    } catch (e) {
      emit(OfferDetailsError('Failed to send counter offer: ${e.toString()}'));
      // Reload the previous state to maintain UI continuity
      emit(currentState);
    }
  }
}
