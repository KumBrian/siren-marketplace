import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/core/domain/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';

import 'package:siren_marketplace/core/domain/models/species.dart';

class Catch extends Equatable {
  final String id;
  final String name;
  final String datePosted;
  final double initialWeight;
  final double availableWeight;
  final double pricePerKg;
  final double total;
  final String size;
  final String market;
  final List<String> images;
  final Species species;
  final String fisherId;
  final List<Offer> offers;
  final CatchStatus status;

  const Catch({
    required this.id,
    required this.name,
    required this.datePosted,
    required this.initialWeight,
    required this.availableWeight,
    required this.pricePerKg,
    required this.total,
    required this.size,
    required this.market,
    required this.images,
    required this.species,
    required this.fisherId,
    this.offers = const [],
    this.status = CatchStatus.available,
  });

  @override
  List<Object> get props => [
    id,
    name,
    datePosted,
    initialWeight,
    availableWeight,
    pricePerKg,
    total,
    size,
    market,
    images,
    species,
    fisherId,
    offers,
    status,
  ];

  int get daysLeft {
    try {
      final posted = DateTime.parse(datePosted);
      final expiry = posted.add(const Duration(days: 7));
      final diff = expiry.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  String get daysLeftLabel {
    final left = daysLeft;
    if (left == 0) return "Expired";
    if (left == 1) return "1 day left";
    return "$left days left";
  }

  Catch copyWith({
    double? availableWeight,
    CatchStatus? status,
    List<Offer>? offers,
    double? pricePerKg,
    double? total,
  }) {
    return Catch(
      id: id,
      name: name,
      datePosted: datePosted,
      initialWeight: initialWeight,
      availableWeight: availableWeight ?? this.availableWeight,
      offers: offers ?? this.offers,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      total: total ?? this.total,
      size: size,
      market: market,
      images: images,
      species: species,
      fisherId: fisherId,
      status: status ?? this.status,
    );
  }
}
