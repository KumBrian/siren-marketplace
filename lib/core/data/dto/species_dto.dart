import 'package:siren_marketplace/core/domain/models/species.dart';

class SpeciesDto {
  final Map<String, dynamic> json;

  SpeciesDto(this.json);

  Species toDomain() {
    return Species(id: json['id'] as String, name: json['name'] as String);
  }

  static Map<String, dynamic> fromDomain(Species species) {
    return {'id': species.id, 'name': species.name};
  }
}
