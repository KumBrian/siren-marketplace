part of 'buyer_market_bloc.dart';

abstract class BuyerMarketEvent {}

/// Load market catches with optional filters & sorting
class LoadMarketCatches extends BuyerMarketEvent {
  final List<Species>? speciesFilter;
  final List<String>? locationFilter;
  final SortBy? sortByDate;
  final SortBy? sortByPrice;

  LoadMarketCatches({
    this.speciesFilter,
    this.locationFilter,
    this.sortByDate,
    this.sortByPrice,
  });
}

/// Refresh market catches using the last applied filters
class RefreshMarketCatches extends BuyerMarketEvent {}
