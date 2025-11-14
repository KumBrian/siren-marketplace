import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart'; // Make sure path is correct
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'offers_event.dart';
part 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OfferRepository _offerRepository;
  final CatchRepository _catchRepository;
  final UserRepository _userRepository;
  final TransactionNotifier _notifier;

  StreamSubscription? _notifierSubscription;

  // Store the last query details to enable auto-refresh
  String? _currentUserId;
  Role? _currentUserRole;

  OffersBloc({
    required OfferRepository offerRepository,
    required TransactionNotifier notifier,
    required CatchRepository catchRepository,
    required UserRepository userRepository,
  }) : _offerRepository = offerRepository,
       _notifier = notifier,
       _catchRepository = catchRepository,
       _userRepository = userRepository,
       super(OffersInitial()) {
    _notifierSubscription = _notifier.updates.listen((_) {
      if (_currentUserId != null && _currentUserRole != null) {
        add(_RefreshOffers()); // ✅ This handles the automatic reload
      }
    });

    on<LoadOffersForUser>(_onLoadOffersForUser);
    on<AddOffer>(_onAddOffer); // Assuming you still need this event
    on<_RefreshOffers>(_onRefreshOffers);
    on<AcceptOffer>(_onAcceptOffer);
    on<RejectOffer>(_onRejectOffer);
    on<CounterOffer>(_onCounterOffer);
    on<MarkOfferAsViewed>(_onMarkOfferAsViewed);
    on<CreateOffer>(_onCreateOffer);
    on<LoadAllFisherOffers>(_onLoadAllFisherOffers);
    on<GetOfferById>(_onGetOfferById);
    // on<LoadOfferDetails>(_onLoadOfferDetails);
  }

  // Future<void> _onLoadOfferDetails(
  //   LoadOfferDetails event,
  //   Emitter<OffersState> emit,
  // ) async {
  //   final currentState = state;
  //   List<Offer> currentOffers = [];
  //   bool wasLoaded = currentState is OffersLoaded;
  //   if (wasLoaded) {
  //     currentOffers = (currentState).offers;
  //   }
  //
  //   // 1. Set temporary loading state for details view
  //   if (wasLoaded) {
  //     // Clear the details immediately while preserving the main offer list
  //     emit(
  //       (currentState).copyWith(
  //         selectedOffer: null,
  //         selectedCatch: null,
  //         selectedFisher: null,
  //       ),
  //     );
  //   } else {
  //     emit(OffersLoading());
  //   }
  //
  //   try {
  //     final Offer? offer = await _offerRepository.getOfferById(event.offerId);
  //
  //     if (offer == null) {
  //       emit(OffersError("Offer with ID ${event.offerId} not found."));
  //       return;
  //     }
  //
  //     // Fetch related entities
  //     final Catch? catchItem = await _catchRepository.getCatchById(
  //       offer.catchId,
  //     );
  //     final fisherMap = await _userRepository.getUserMapById(offer.fisherId);
  //     final Fisher? fisher = fisherMap != null
  //         ? Fisher.fromMap(fisherMap)
  //         : null;
  //
  //     // 2. Emit the final OffersLoaded state with the details populated
  //     emit(
  //       OffersLoaded(
  //         currentOffers, // Pass the existing list of offers
  //         selectedOffer: offer,
  //         selectedCatch: catchItem,
  //         selectedFisher: fisher,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(OffersError("Failed to load offer details: ${e.toString()}"));
  //   }
  // }

  // 🔑 FIX: Update the details *before* emitting OfferActionSuccess
  Future<void> _onAcceptOffer(
    AcceptOffer event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    try {
      // 1. Perform complex transaction (updates offer, creates order)
      final (updatedOffer, newOrderId) = await _offerRepository.acceptOffer(
        offer: event.offer,
        catchItem: event.catchItem,
        fisher: event.fisher,
        orderRepo: event.orderRepository,
      );

      // 2. CRITICAL FIX: If we are on the details screen (OffersLoaded),
      //    update the selectedOffer in the state.
      if (currentState is OffersLoaded) {
        emit(currentState.copyWith(selectedOffer: updatedOffer));
      }

      if (currentState is OfferDetailsLoaded &&
          currentState.offer.id == updatedOffer.id) {
        // Re-fetch related entities to maintain consistency, or just use the updated ones
        final Catch? catchItem = await _catchRepository.getCatchById(
          updatedOffer.catchId,
        );
        final fisherMap = await _userRepository.getUserMapById(
          updatedOffer.fisherId,
        );
        final Fisher? fisher = fisherMap != null
            ? Fisher.fromMap(fisherMap)
            : null;

        if (catchItem != null && fisher != null) {
          emit(OfferDetailsLoaded(updatedOffer, catchItem, fisher));
        }
      }

      // 3. Emit success state for the listener/dialog
      emit(OfferActionSuccess('Accept', updatedOffer, newOrderId));
    } catch (e) {
      // Emit failure state to dismiss the loading dialog
      emit(OfferActionFailure('Accept', 'Failed to accept offer.'));
      print('Error accepting offer: $e');
    }
  }

  // 🔑 FIX: Update the details *before* emitting OfferActionSuccess
  Future<void> _onRejectOffer(
    RejectOffer event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    try {
      final updatedOffer = await _offerRepository.rejectOffer(event.offer);

      // 2. CRITICAL FIX: If we are on the details screen (OffersLoaded),
      //    update the selectedOffer in the state.
      if (currentState is OffersLoaded) {
        emit(currentState.copyWith(selectedOffer: updatedOffer));
      }

      // 3. Emit success state for the listener/dialog
      emit(OfferActionSuccess('Reject', updatedOffer, null));
    } catch (e) {
      print('Error rejecting offer: $e');
      emit(OfferActionFailure('Reject', 'Failed to reject offer.'));
    }
  }

  // 🔑 FIX: Update the details *before* emitting OfferActionSuccess
  Future<void> _onCounterOffer(
    CounterOffer event,
    Emitter<OffersState> emit,
  ) async {
    final currentState = state;
    try {
      final updatedOffer = await _offerRepository.counterOffer(
        previous: event.previousOffer,
        newPrice: event.newPrice,
        newWeight: event.newWeight,
        role: event.counteringRole,
      );

      // 2. CRITICAL FIX: If we are on the details screen (OffersLoaded),
      //    update the selectedOffer in the state.
      if (currentState is OffersLoaded) {
        emit(currentState.copyWith(selectedOffer: updatedOffer));
      }

      // 3. Emit success state for the listener/dialog
      emit(OfferActionSuccess('Counter', updatedOffer, null));
    } catch (e) {
      print('Error countering offer: $e');
      emit(OfferActionFailure('Counter', 'Failed to send counter offer.'));
    }
  }

  Future<void> _onGetOfferById(
    GetOfferById event,
    Emitter<OffersState> emit,
  ) async {
    // 1. Emit loading state if current state isn't already a details loaded state
    if (state is! OfferDetailsLoaded ||
        (state as OfferDetailsLoaded).offer.id != event.offerId) {
      emit(OffersLoading());
    }

    try {
      final Offer? offer = await _offerRepository.getOfferById(event.offerId);
      final catchSnapShot = await _catchRepository.getCatchById(offer!.catchId);
      final fisherMap = await _userRepository.getUserMapById(offer.fisherId);
      final fisher = fisherMap != null ? Fisher.fromMap(fisherMap) : null;

      emit(OfferDetailsLoaded(offer, catchSnapShot!, fisher!));
    } catch (e) {
      emit(OffersError("Failed to load offer details: $e"));
    }
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
      final offerMaps = await _offerRepository.getOfferMapsByCatchIds(
        event.catchIds,
      );

      // 2. Assemble Offer objects
      final offers = offerMaps.map((map) => Offer.fromMap(map)).toList();

      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onCreateOffer(
    CreateOffer event,
    Emitter<OffersState> emit,
  ) async {
    try {
      // This is perfect. Notifier handles the refresh.
      await _offerRepository.createOffer(
        catchId: event.catchId,
        buyerId: event.buyerId,
        fisherId: event.fisherId,
        price: event.price,
        weight: event.weight,
        pricePerKg: event.pricePerKg,
      );
    } catch (e) {
      print('Error creating offer: $e');
    }
  }

  Future<void> _onAddOffer(AddOffer event, Emitter<OffersState> emit) async {
    try {
      // ✅ CORRECTED: Trust the notifier.
      await _offerRepository.insertOffer(event.offer);
    } catch (e) {
      print('Error adding offer: $e');
    }
  }

  Future<void> _onMarkOfferAsViewed(
    MarkOfferAsViewed event,
    Emitter<OffersState> emit,
  ) async {
    final bool needsUpdate = event.viewingRole == Role.fisher
        ? event.offer.hasUpdateForFisher
        : event.offer.hasUpdateForBuyer;

    if (!needsUpdate) return;

    final viewedOffer = event.offer.copyWith(
      hasUpdateForFisher: event.viewingRole == Role.fisher ? false : null,
      hasUpdateForBuyer: event.viewingRole == Role.buyer ? false : null,
    );
    try {
      await _offerRepository.updateOffer(viewedOffer);
      _notifier.notify();
    } catch (e) {
      print('Failed to mark offer as viewed: ${e.toString()}');
    }
  }

  Future<void> _onLoadOffersForUser(
    LoadOffersForUser event,
    Emitter<OffersState> emit,
  ) async {
    // Store user details for refreshing
    _currentUserId = event.userId;
    _currentUserRole = event.role;

    emit(OffersLoading());
    await _fetchAndEmitOffers(emit);
  }

  Future<void> _onRefreshOffers(
    _RefreshOffers event,
    Emitter<OffersState> emit,
  ) async {
    // This is perfect. No loading state for background refresh.
    await _fetchAndEmitOffers(emit);
  }

  Future<void> _fetchAndEmitOffers(Emitter<OffersState> emit) async {
    if (_currentUserId == null || _currentUserRole == null) return;

    try {
      List<Map<String, dynamic>> offerMaps;

      if (_currentUserRole == Role.buyer) {
        offerMaps = await _offerRepository.getOfferMapsByBuyerId(
          _currentUserId!,
        );
      } else if (_currentUserRole == Role.fisher) {
        offerMaps = await _offerRepository.getOfferMapsByFisherId(
          _currentUserId!,
        );
      } else {
        offerMaps = [];
      }

      final offers = offerMaps.map((map) => Offer.fromMap(map)).toList();

      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notifierSubscription?.cancel();
    return super.close();
  }
}
