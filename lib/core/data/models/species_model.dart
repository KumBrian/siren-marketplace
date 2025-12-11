import 'package:siren_marketplace/core/domain/entities/species.dart';

class SpeciesModel extends Species {
  const SpeciesModel({
    required super.id,
    required super.uid,
    required super.name,
    required super.image,
    super.scientificName = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'name': name,
    'image': image,
    'scientific_name': scientificName,
  };

  factory SpeciesModel.fromJson(Map<String, dynamic> json) => SpeciesModel(
    id: json['id'] as String,
    uid:
        json['uid'] as String? ??
        json['id'] as String, // Fallback to id if uid missing
    name: json['name'] as String,
    image: json['image'] as String,
    scientificName: (json['scientific_name'] as String?) ?? '',
  );

  Map<String, dynamic> toMap() => toJson();

  factory SpeciesModel.fromMap(Map<String, dynamic> map) =>
      SpeciesModel.fromJson(map);
}
