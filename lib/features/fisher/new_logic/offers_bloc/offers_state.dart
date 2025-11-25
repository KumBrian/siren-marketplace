part of 'offers_cubit.dart';

class OffersState extends Equatable {
  final bool loading;
  final List<Offer> offers;
  final String? error;
  final Order? order;
  final Offer? updatedOffer;
  final bool? markAsViewed;

  const OffersState({
    this.loading = false,
    this.offers = const [],
    this.error,
    this.order,
    this.updatedOffer,
    this.markAsViewed,
  });

  OffersState copyWith({
    bool? loading,
    List<Offer>? offers,
    String? error,
    Order? order,
    Offer? updatedOffer,
    bool? markAsViewed,
  }) {
    return OffersState(
      loading: loading ?? this.loading,
      offers: offers ?? this.offers,
      error: error,
      order: order,
      updatedOffer: updatedOffer,
    );
  }

  @override
  List<Object?> get props => [loading, offers, error, order];
}
