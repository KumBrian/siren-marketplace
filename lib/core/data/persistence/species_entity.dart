import 'package:siren_marketplace/core/domain/models/species.dart';

class SpeciesEntity {
  final String id;
  final String name;

  SpeciesEntity({required this.id, required this.name});

  factory SpeciesEntity.fromMap(Map<String, dynamic> map) =>
      SpeciesEntity(id: map['id'] as String, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  Species toDomain() => Species(id: id, name: name);

  static SpeciesEntity fromDomain(Species species) =>
      SpeciesEntity(id: species.id, name: species.name);
}
