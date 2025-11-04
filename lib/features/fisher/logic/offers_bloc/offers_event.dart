part of 'offers_bloc.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all offers relevant to a specific user.
/// The BLoC will use the [role] to decide which repo method to call.
class LoadOffersForUser extends OffersEvent {
  final String userId;
  final Role role; // The role of the user (e.g., Role.fisher or Role.buyer)

  const LoadOffersForUser({required this.userId, required this.role});

  @override
  List<Object> get props => [userId, role];
}

class GetOfferById extends OffersEvent {
  final String offerId;

  const GetOfferById(this.offerId);

  @override
  List<Object> get props => [offerId];
}

class AddOffer extends OffersEvent {
  final Offer offer;

  const AddOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

class LoadAllFisherOffers extends OffersEvent {
  final List<String> catchIds; // List of all Catch IDs belonging to the Fisher

  const LoadAllFisherOffers(this.catchIds);

  @override
  List<Object?> get props => [catchIds];
}

/// Event to accept an offer.
class AcceptOffer extends OffersEvent {
  final Offer offer;
  final Catch catchItem;
  final Fisher fisher;

  // Required by the OfferRepository.acceptOffer method
  final OrderRepository orderRepository;

  const AcceptOffer({
    required this.offer,
    required this.catchItem,
    required this.fisher,
    required this.orderRepository,
  });

  @override
  List<Object?> get props => [offer, catchItem, fisher, orderRepository];
}

/// Event to reject an offer.
class RejectOffer extends OffersEvent {
  final Offer offer;

  const RejectOffer({required this.offer});

  @override
  List<Object> get props => [offer];
}

/// Event to counter an offer.
class CounterOffer extends OffersEvent {
  final Offer previousOffer;
  final double newPrice;
  final double newWeight;
  final Role counteringRole; // The role of the person making the counter

  const CounterOffer({
    required this.previousOffer,
    required this.newPrice,
    required this.newWeight,
    required this.counteringRole,
  });

  @override
  List<Object> get props => [
    previousOffer,
    newPrice,
    newWeight,
    counteringRole,
  ];
}

class MarkOfferAsViewed extends OffersEvent {
  final Offer offer;
  final Role viewingRole;

  const MarkOfferAsViewed(this.offer, this.viewingRole);

  @override
  List<Object> get props => [offer, viewingRole];
}

class CreateOffer extends OffersEvent {
  final String catchId;
  final String buyerId;
  final String fisherId;
  final double price;
  final double weight;
  final double pricePerKg;

  const CreateOffer({
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

class LoadOfferDetails extends OffersEvent {
  final String offerId;

  const LoadOfferDetails(this.offerId);

  @override
  List<Object> get props => [offerId];
}

/// An internal event used by the notifier to trigger a refresh.
class _RefreshOffers extends OffersEvent {}
