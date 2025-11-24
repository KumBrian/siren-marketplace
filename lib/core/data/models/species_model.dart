class SpeciesModel {
  final String id;
  final String name;
  final String? scientificName;

  const SpeciesModel({
    required this.id,
    required this.name,
    this.scientificName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientific_name': scientificName,
  };

  factory SpeciesModel.fromJson(Map<String, dynamic> json) => SpeciesModel(
    id: json['id'] as String,
    name: json['name'] as String,
    scientificName: json['scientific_name'] as String?,
  );

  Map<String, dynamic> toMap() => toJson();

  factory SpeciesModel.fromMap(Map<String, dynamic> map) =>
      SpeciesModel.fromJson(map);
}
