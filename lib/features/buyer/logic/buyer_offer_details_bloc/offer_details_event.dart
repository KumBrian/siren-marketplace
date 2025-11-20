// lib/bloc/offer_details_bloc/offer_details_event.dart

part of 'offer_details_bloc.dart';

abstract class OfferDetailsEvent extends Equatable {
  const OfferDetailsEvent();

  @override
  // Note: The signature List<Object?> is used for compatibility with the base state.
  List<Object?> get props => [];
}

// 1. Event to trigger the initial loading of all required models
class LoadOfferDetails extends OfferDetailsEvent {
  final String offerId;

  const LoadOfferDetails(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

class LoadOffers extends OfferDetailsEvent {
  final String catchId;

  const LoadOffers(this.catchId);

  @override
  List<Object?> get props => [catchId];
}

// 2. 🆕 Event to accept the current offer/counter-offer
class AcceptOffer extends OfferDetailsEvent {
  final Offer offer;
  final Catch catchItem;
  final Fisher fisher;

  const AcceptOffer({
    required this.offer,
    required this.catchItem,
    required this.fisher,
  });

  @override
  List<Object?> get props => [offer, catchItem, fisher];
}

// 3. 🆕 Event to send a new offer or a counter-offer
class SendCounterOffer extends OfferDetailsEvent {
  final Offer offer; // The ID of the offer being responded to
  final int newWeight;
  final int newPrice;
  final Role role;

  const SendCounterOffer({
    required this.offer,
    required this.newWeight,
    required this.newPrice,
    required this.role,
  });

  @override
  List<Object?> get props => [offer, newWeight, newPrice, role];
}

class MarkOfferAsViewed extends OfferDetailsEvent {
  final Role viewingRole;

  const MarkOfferAsViewed(this.viewingRole);

  @override
  List<Object> get props => [viewingRole];
}
