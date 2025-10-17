part of 'offer_bloc.dart';

abstract class OffersState extends Equatable {
  @override
  List<Object?> get props => [];
}

// --- Base states ---
class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<Offer> offers;

  OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OffersError extends OffersState {
  final String message;

  OffersError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Action-specific transient states ---
// These exist to give the UI feedback when a user accepts, rejects, or counters.

class OfferActionInProgress extends OffersState {
  final String action; // e.g. "accept", "reject", "counter"
  OfferActionInProgress(this.action);

  @override
  List<Object?> get props => [action];
}

class OfferActionSuccess extends OffersState {
  final String? orderId;
  final String action;
  final Offer updatedOffer;

  OfferActionSuccess(this.action, this.updatedOffer, this.orderId);

  @override
  List<Object?> get props => [action, updatedOffer, orderId];
}

class OfferActionFailure extends OffersState {
  final String action;
  final String error;

  OfferActionFailure(this.action, this.error);

  @override
  List<Object?> get props => [action, error];
}
