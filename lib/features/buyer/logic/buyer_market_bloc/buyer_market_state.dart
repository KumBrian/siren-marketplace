part of 'buyer_market_bloc.dart';

abstract class BuyerMarketState {}

class BuyerMarketInitial extends BuyerMarketState {}

class BuyerMarketLoading extends BuyerMarketState {}

class BuyerMarketLoaded extends BuyerMarketState {
  final List<Catch> catches;

  BuyerMarketLoaded(this.catches);
}

class BuyerMarketError extends BuyerMarketState {
  final String message;

  BuyerMarketError(this.message);
}
