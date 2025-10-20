part of 'offer_bloc.dart';

abstract class OffersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOffers extends OffersEvent {
  final String catchId;

  LoadOffers(this.catchId);

  @override
  List<Object?> get props => [catchId];
}

class AddOffer extends OffersEvent {
  final Offer offer;

  AddOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

class UpdateOfferEvent extends OffersEvent {
  final Offer offer;

  UpdateOfferEvent(this.offer);

  @override
  List<Object?> get props => [offer];
}

class DeleteOfferEvent extends OffersEvent {
  final String offerId;

  DeleteOfferEvent(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

class LoadAllFisherOffers extends OffersEvent {
  final List<String> catchIds; // List of all Catch IDs belonging to the Fisher

  LoadAllFisherOffers(this.catchIds);

  @override
  List<Object?> get props => [catchIds];
}

class AcceptOfferEvent extends OffersEvent {
  final Offer offer;
  final Catch catchItem;
  final Fisher fisher;

  AcceptOfferEvent(this.offer, this.catchItem, this.fisher);

  @override
  List<Object?> get props => [offer, catchItem, fisher];
}

class RejectOfferEvent extends OffersEvent {
  final Offer offer;

  RejectOfferEvent(this.offer);

  @override
  List<Object?> get props => [offer];
}

class CounterOfferEvent extends OffersEvent {
  final Offer previous;
  final double newPrice;
  final double newWeight;

  CounterOfferEvent(this.previous, this.newPrice, this.newWeight);

  @override
  List<Object?> get props => [previous, newPrice, newWeight];
}

class CreateOfferEvent extends OffersEvent {
  final String catchId;
  final String buyerId;
  final String fisherId;
  final double price;
  final double weight;
  final double pricePerKg;

  CreateOfferEvent({
    required this.catchId,
    required this.buyerId,
    required this.fisherId,
    required this.price,
    required this.weight,
    required this.pricePerKg,
  });

  @override
  List<Object?> get props => [catchId, buyerId, price, weight, pricePerKg];
}

class LoadBuyerOffersEvent extends OffersEvent {
  final String buyerId;

  LoadBuyerOffersEvent(this.buyerId);

  @override
  List<Object?> get props => [buyerId];
}
