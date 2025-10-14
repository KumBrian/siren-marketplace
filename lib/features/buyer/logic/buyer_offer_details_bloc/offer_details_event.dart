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

// 2. 🆕 Event to accept the current offer/counter-offer
class AcceptOffer extends OfferDetailsEvent {
  final String offerId;

  const AcceptOffer({required this.offerId});

  @override
  List<Object?> get props => [offerId];
}

// 3. 🆕 Event to send a new offer or a counter-offer
class SendCounterOffer extends OfferDetailsEvent {
  final String offerId; // The ID of the offer being responded to
  final double newWeight;
  final double newPrice;
  final bool isCounter; // True if it's a counter to the previous offer

  const SendCounterOffer({
    required this.offerId,
    required this.newWeight,
    required this.newPrice,
    required this.isCounter,
  });

  @override
  List<Object?> get props => [offerId, newWeight, newPrice, isCounter];
}
