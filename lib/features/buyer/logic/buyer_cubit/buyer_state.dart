part of 'buyer_cubit.dart';

abstract class BuyerState extends Equatable {
  const BuyerState();

  @override
  List<Object> get props => [];
}

class BuyerInitial extends BuyerState {}

class BuyerLoading extends BuyerState {}

class BuyerLoaded extends BuyerState {
  final Buyer buyer;

  // 🆕 Include the full list of assembled orders for the buyer
  final List<Order> orders;
  final List<Offer> madeOffers;

  const BuyerLoaded({
    required this.buyer,
    required this.orders,
    required this.madeOffers,
  });

  @override
  List<Object> get props => [buyer, orders, madeOffers];
}

class BuyerError extends BuyerState {
  final String message;

  const BuyerError(this.message);

  @override
  List<Object> get props => [message];
}
