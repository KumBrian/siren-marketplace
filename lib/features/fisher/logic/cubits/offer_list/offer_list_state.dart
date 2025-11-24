import 'package:equatable/equatable.dart';

import '../../../../../new_core/domain/entities/offer.dart';

abstract class OfferListState extends Equatable {
  const OfferListState();

  @override
  List<Object?> get props => [];
}

class OfferListInitial extends OfferListState {
  const OfferListInitial();
}

class OfferListLoading extends OfferListState {
  const OfferListLoading();
}

class OfferListLoaded extends OfferListState {
  final List<Offer> offers;

  const OfferListLoaded({required this.offers});

  @override
  List<Object?> get props => [offers];
}

class OfferListError extends OfferListState {
  final String message;

  const OfferListError(this.message);

  @override
  List<Object?> get props => [message];
}
