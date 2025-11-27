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
    this.action,
  });

  final String? action;

  Offer? get selectedOffer => updatedOffer;

  OffersState copyWith({
    bool? loading,
    List<Offer>? offers,
    String? error,
    Order? order,
    Offer? updatedOffer,
    bool? markAsViewed,
    String? action,
  }) {
    return OffersState(
      loading: loading ?? this.loading,
      offers: offers ?? this.offers,
      error: error,
      order: order,
      updatedOffer: updatedOffer,
      action: action,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    offers,
    error,
    order,
    updatedOffer,
    action,
  ];
}
