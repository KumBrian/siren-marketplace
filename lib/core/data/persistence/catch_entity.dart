import 'dart:convert';

import 'package:siren_marketplace/core/domain/models/species.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';

import '../../domain/models/catch.dart';

class CatchEntity {
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
  final CatchStatus status;

  CatchEntity({
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
    required this.status,
  });

  factory CatchEntity.fromMap(Map<String, dynamic> m) => CatchEntity(
    id: m['catch_id'] as String,
    name: m['name'] as String,
    datePosted: m['date_created'] as String,
    initialWeight: (m['initial_weight'] as num).toDouble(),
    availableWeight: (m['available_weight'] as num).toDouble(),
    pricePerKg: (m['price_per_kg'] as num).toDouble(),
    total: (m['total'] as num).toDouble(),
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

  Catch toDomain() => Catch(
    id: id,
    name: name,
    datePosted: datePosted,
    initialWeight: initialWeight,
    availableWeight: availableWeight,
    pricePerKg: pricePerKg,
    total: total,
    size: size,
    market: market,
    images: images,
    species: species,
    fisherId: fisherId,
    status: status,
  );

  static CatchEntity fromDomain(Catch c) => CatchEntity(
    id: c.id,
    name: c.name,
    datePosted: c.datePosted,
    initialWeight: c.initialWeight,
    availableWeight: c.availableWeight,
    pricePerKg: c.pricePerKg,
    total: c.total,
    size: c.size,
    market: c.market,
    images: c.images,
    species: c.species,
    fisherId: c.fisherId,
    status: c.status,
  );
}
