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

  const OfferDetailsLoaded(this.offer, this.catchItem, this.fisher);

  // 2. 🔑 Change to List<Object?> here as well.
  @override
  List<Object?> get props => [offer, catchItem, fisher];
}
