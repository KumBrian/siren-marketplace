import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../types/converters.dart' show catchStatusFromString;
import '../types/enum.dart' show CatchStatus;
import 'offer.dart';
import 'species.dart' show Species;

class Catch extends Equatable {
  final String id;
  final String name;
  final String datePosted;
  final int initialWeight; //Weight in grams
  final int availableWeight; //Weight in grams
  final int pricePerKg;
  final int total;
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
    images, // Equatable correctly compares List contents
    species, // Species is Equatable
    fisherId,
    offers, // Offers is Equatable
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

  // Used for transactional updates (e.g., reducing availableWeight)
  Catch copyWith({
    int? availableWeight,
    CatchStatus? status,
    List<Offer>? offers,
    int? pricePerKg,
    int? total,
  }) {
    return Catch(
      id: id,
      name: name,
      datePosted: datePosted,
      initialWeight: initialWeight,
      // Only mutable fields are updated
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

  // --- DB Mapping ---

  Map<String, dynamic> toMap() => {
    'catch_id': id,
    'name': name,
    'date_created': datePosted,
    'initial_weight': initialWeight,
    'available_weight': availableWeight,
    'price_per_kg': pricePerKg,
    'total': total,
    'size': size,
    'market': market,
    'species_id': species.id,
    'species_name': species.name,
    'fisher_id': fisherId,
    'images': jsonEncode(images),
    'status': status.name,
  };

  factory Catch.fromMap(Map<String, dynamic> m) => Catch(
    id: m['catch_id'] as String,
    name: m['name'] as String,
    datePosted: m['date_created'] as String,
    initialWeight: (m['initial_weight'] as num).toInt(),
    availableWeight: (m['available_weight'] as num).toInt(),
    pricePerKg: (m['price_per_kg'] as num).toInt(),
    total: (m['total'] as num).toInt(),
    size: m['size'] as String,
    market: m['market'] as String,
    species: Species(
      id: m['species_id'] as String,
      name: m['species_name'] as String,
    ),
    fisherId: m['fisher_id'] as String,
    images:
        (m['images'] == null ||
            m['images'] is! String ||
            (m['images'] as String).isEmpty)
        ? []
        : List<String>.from(jsonDecode(m['images'] as String)),
    status: catchStatusFromString(m['status'] as String? ?? 'available'),
  );

  factory Catch.empty() => Catch(
    id: '',
    name: 'Unknown',
    datePosted: '',
    initialWeight: 0,
    availableWeight: 0,
    pricePerKg: 0,
    total: 0,
    size: '',
    market: '',
    species: Species(id: '', name: ''),
    fisherId: '',
    images: [],
    offers: [],
  );
}
