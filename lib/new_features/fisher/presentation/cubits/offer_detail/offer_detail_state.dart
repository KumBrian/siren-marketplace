import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/new_core/domain/entities/user.dart';

import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/entities/offer.dart';
import '../../../../../new_core/domain/entities/order.dart';

abstract class OfferDetailState extends Equatable {
  const OfferDetailState();

  @override
  List<Object?> get props => [];
}

class OfferDetailInitial extends OfferDetailState {
  const OfferDetailInitial();
}

class OfferDetailLoading extends OfferDetailState {
  const OfferDetailLoading();
}

class OfferDetailLoaded extends OfferDetailState {
  final Offer offer;
  final Catch relatedCatch;
  final User counterparty; // Fisher or Buyer
  final Order? linkedOrder; // If offer is accepted
  final bool isProcessing;

  const OfferDetailLoaded({
    required this.offer,
    required this.relatedCatch,
    required this.counterparty,
    this.linkedOrder,
    this.isProcessing = false,
  });

  OfferDetailLoaded copyWith({
    Offer? offer,
    Catch? relatedCatch,
    User? counterparty,
    Order? linkedOrder,
    bool? isProcessing,
  }) {
    return OfferDetailLoaded(
      offer: offer ?? this.offer,
      relatedCatch: relatedCatch ?? this.relatedCatch,
      counterparty: counterparty ?? this.counterparty,
      linkedOrder: linkedOrder ?? this.linkedOrder,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
    offer,
    relatedCatch,
    counterparty,
    linkedOrder,
    isProcessing,
  ];
}

class OfferDetailError extends OfferDetailState {
  final String message;

  const OfferDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
