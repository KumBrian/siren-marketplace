import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/types/enum.dart' show Role;

class Fisher extends AppUser {
  final List<Catch> catches; // To be loaded from CatchRepository
  final List<Offer> receivedOffers; // To be loaded from OfferRepository

  const Fisher({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewCount,
    this.catches = const [],
    this.receivedOffers = const [],
  }) : super(role: Role.fisher);

  @override
  List<Object> get props => [...super.props, catches, receivedOffers];

  factory Fisher.fromMap(Map<String, dynamic> m) {
    final appUser = AppUser.fromMap(m);
    return Fisher(
      id: appUser.id,
      name: appUser.name,
      avatarUrl: appUser.avatarUrl,
      rating: appUser.rating,
      reviewCount: appUser.reviewCount,
      catches: const [],
      receivedOffers: const [],
    );
  }
}
