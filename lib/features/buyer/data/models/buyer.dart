import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';

class Buyer extends AppUser {
  final List<Offer> madeOffers;
  final List<Order> orders;

  const Buyer({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewCount,
    this.madeOffers = const [],
    this.orders = const [],
  }) : super(role: Role.buyer);

  @override
  List<Object> get props => [...super.props, madeOffers, orders];

  factory Buyer.fromMap(Map<String, dynamic> m) {
    final appUser = AppUser.fromMap(m);
    return Buyer(
      id: appUser.id,
      name: appUser.name,
      avatarUrl: appUser.avatarUrl,
      rating: appUser.rating,
      reviewCount: appUser.reviewCount,
      madeOffers: const [],
      orders: const [],
    );
  }
}
