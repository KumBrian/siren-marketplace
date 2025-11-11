part of 'offers_bloc.dart';

abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object> get props => [message];
}

class OfferActionInProgress extends OffersState {
  final String action;

  const OfferActionInProgress(this.action);

  @override
  List<Object> get props => [action];
}

class OfferActionSuccess extends OffersState {
  final String? orderId;
  final String action;
  final Offer updatedOffer;

  const OfferActionSuccess(this.action, this.updatedOffer, this.orderId);

  @override
  List<Object> get props => [action, updatedOffer, ?orderId];
}

class OfferActionFailure extends OffersState {
  final String action;
  final String error;

  const OfferActionFailure(this.action, this.error);

  @override
  List<Object> get props => [action, error];
}

class OfferDetailsLoaded extends OffersState {
  final Offer offer;
  final Catch catchSnapshot;
  final Fisher fisher;

  const OfferDetailsLoaded(this.offer, this.catchSnapshot, this.fisher);

  @override
  List<Object> get props => [offer];
}

class OffersLoaded extends OffersState {
  final List<Offer> offers;

  // 🎯 New fields for the selected offer details:
  final Offer? selectedOffer;
  final Catch? selectedCatch;
  final Fisher? selectedFisher;

  const OffersLoaded(
    this.offers, {
    this.selectedOffer,
    this.selectedCatch,
    this.selectedFisher,
  });

  // 🎯 Add copyWith for non-destructive state updates
  OffersLoaded copyWith({
    List<Offer>? offers,
    Offer? selectedOffer,
    Catch? selectedCatch,
    Fisher? selectedFisher,
  }) {
    return OffersLoaded(
      offers ?? this.offers,
      selectedOffer: selectedOffer,
      selectedCatch: selectedCatch,
      selectedFisher: selectedFisher,
    );
  }

  // Ensure props are updated
  @override
  List<Object> get props => [
    // 🎯 The return type is now List<Object>
    offers,

    // 🎯 Use the spread operator to conditionally include non-null objects
    if (selectedOffer != null) selectedOffer!,
    if (selectedCatch != null) selectedCatch!,
    if (selectedFisher != null) selectedFisher!,
  ];
}
