import 'dart:convert';

import 'package:siren_marketplace/core/domain/models/catch.dart';
import 'package:siren_marketplace/core/domain/models/species.dart';
import 'package:siren_marketplace/core/types/converters.dart';

class CatchDto {
  final Map<String, dynamic> json;

  CatchDto(this.json);

  Catch toDomain() {
    return Catch(
      id: json['catch_id'] as String,
      name: json['name'] as String,
      datePosted: json['date_created'] as String,
      initialWeight: (json['initial_weight'] as num).toDouble(),
      availableWeight: (json['available_weight'] as num).toDouble(),
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      size: json['size'] as String,
      market: json['market'] as String,
      species: Species(
        id: json['species_id'] as String,
        name: json['species_name'] as String,
      ),
      fisherId: json['fisher_id'] as String,
      images:
          (json['images'] == null ||
              json['images'] is! String ||
              (json['images'] as String).isEmpty)
          ? []
          : List<String>.from(jsonDecode(json['images'] as String)),
      status: catchStatusFromString(json['status'] as String? ?? 'available'),
    );
  }

  static Map<String, dynamic> fromDomain(Catch c) {
    return {
      'catch_id': c.id,
      'name': c.name,
      'date_created': c.datePosted,
      'initial_weight': c.initialWeight,
      'available_weight': c.availableWeight,
      'price_per_kg': c.pricePerKg,
      'total': c.total,
      'size': c.size,
      'market': c.market,
      'species_id': c.species.id,
      'species_name': c.species.name,
      'fisher_id': c.fisherId,
      'images': jsonEncode(c.images),
      'status': c.status.name,
    };
  }
}
