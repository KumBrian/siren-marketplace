// lib/bloc/cubits/offer_details_cubit/offer_details_state.dart

part of 'offer_details_bloc.dart';

// Ensure the base class is abstract and defines the nullable signature
abstract class OfferDetailsState {
  const OfferDetailsState();

  // 1. 🔑 Change to List<Object?> to match EquatableMixin's required signature.
  List<Object?> get props;
}

class OfferDetailsInitial extends OfferDetailsState {
  @override
  List<Object?> get props => [];
}

class OffersLoaded extends OfferDetailsState {
  final List<Offer> offers;

  OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OfferDetailsLoading extends OfferDetailsState {
  @override
  List<Object?> get props => [];
}

class OfferDetailsError extends OfferDetailsState {
  final String message;

  const OfferDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class OfferDetailsLoaded extends OfferDetailsState with EquatableMixin {
  final Offer offer;
  final Catch catchItem;
  final Fisher fisher;

  // 🆕 ADDED: Transient identifier for one-time success messages
  final String? successMessageId;

  const OfferDetailsLoaded(
    this.offer,
    this.catchItem,
    this.fisher, {
    this.successMessageId, // 🔑 Include in constructor
  });

  // 🔑 Updated to include the new field
  @override
  List<Object?> get props => [offer, catchItem, fisher, successMessageId];

  // 🆕 ADDED: copyWith for easily generating new states
  OfferDetailsLoaded copyWith({
    Offer? offer,
    Catch? catchItem,
    Fisher? fisher,
    String? successMessageId,
  }) {
    return OfferDetailsLoaded(
      offer ?? this.offer,
      catchItem ?? this.catchItem,
      fisher ?? this.fisher,
      successMessageId: successMessageId,
    );
  }
}
