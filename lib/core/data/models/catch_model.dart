import 'dart:convert';

import 'species_model.dart';

class CatchModel {
  final String id;
  final String name;
  final String datePosted;
  final int initialWeightGrams;
  final int availableWeightGrams;
  final int pricePerKgAmount;
  final int totalPriceAmount;
  final String size;
  final String market;
  final List<String> images;
  final SpeciesModel species;
  final String fisherId;
  final String status;
  final String observationId;
  final String locationName;
  final double latitude;
  final double longitude;
  // New Fields
  final double? meshSize;
  final double? gearLength;
  final double? gearWidth;
  final String? gearNature;
  final double? waterDepth;
  final double? fishingTime;
  final int? numberOfShrimps;

  const CatchModel({
    required this.id,
    required this.name,
    required this.datePosted,
    required this.initialWeightGrams,
    required this.availableWeightGrams,
    required this.pricePerKgAmount,
    required this.totalPriceAmount,
    required this.size,
    required this.market,
    required this.images,
    required this.species,
    required this.fisherId,
    required this.status,
    required this.observationId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.meshSize,
    this.gearLength,
    this.gearWidth,
    this.gearNature,
    this.waterDepth,
    this.fishingTime,
    this.numberOfShrimps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date_posted': datePosted,
    'initial_weight_grams': initialWeightGrams,
    'available_weight_grams': availableWeightGrams,
    'price_per_kg_amount': pricePerKgAmount,
    'total_price_amount': totalPriceAmount,
    'size': size,
    'market': market,
    'images': images,
    'species': species.toJson(),
    'fisher_id': fisherId,
    'status': status,
    'observation_id': observationId,
    'location_name': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'mesh_size': meshSize,
    'gear_length': gearLength,
    'gear_width': gearWidth,
    'gear_nature': gearNature,
    'water_depth': waterDepth,
    'fishing_time': fishingTime,
    'number_of_shrimps': numberOfShrimps,
  };

  factory CatchModel.fromJson(Map<String, dynamic> json) => CatchModel(
    id: json['id'] as String,
    name: json['name'] as String,
    datePosted: json['date_posted'] as String,
    initialWeightGrams: (json['initial_weight_grams'] as num).toInt(),
    availableWeightGrams: (json['available_weight_grams'] as num).toInt(),
    pricePerKgAmount: (json['price_per_kg_amount'] as num).toInt(),
    totalPriceAmount: (json['total_price_amount'] as num).toInt(),
    size: json['size'] as String,
    market: json['market'] as String,
    images: List<String>.from(json['images'] as List),
    species: SpeciesModel.fromJson(json['species'] as Map<String, dynamic>),
    fisherId: json['fisher_id'] as String,
    status: json['status'] as String,
    observationId: json['observation_id'] as String,
    locationName: json['location_name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    meshSize: (json['mesh_size'] as num?)?.toDouble(),
    gearLength: (json['gear_length'] as num?)?.toDouble(),
    gearWidth: (json['gear_width'] as num?)?.toDouble(),
    gearNature: json['gear_nature'] as String?,
    waterDepth: (json['water_depth'] as num?)?.toDouble(),
    fishingTime: (json['fishing_time'] as num?)?.toDouble(),
    numberOfShrimps: (json['number_of_shrimps'] as num?)?.toInt(),
  );

  // SQLite mapping (flattened species)
  Map<String, dynamic> toMap() => {
    'catch_id': id,
    'name': name,
    'date_created': datePosted,
    'initial_weight': initialWeightGrams,
    'available_weight': availableWeightGrams,
    'price_per_kg': pricePerKgAmount,
    'total': totalPriceAmount,
    'size': size,
    'market': market,
    'images': jsonEncode(images),
    'species_id': species.id,
    'species_name': species.name,
    'species_image': species.image,
    'fisher_id': fisherId,
    'status': status,
    'observation_id': observationId,
    'location_name': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'mesh_size': meshSize,
    'gear_length': gearLength,
    'gear_width': gearWidth,
    'gear_nature': gearNature,
    'water_depth': waterDepth,
    'fishing_time': fishingTime,
    'number_of_shrimps': numberOfShrimps,
  };

  factory CatchModel.fromMap(Map<String, dynamic> map) => CatchModel(
    id: map['catch_id'] as String,
    name: map['name'] as String,
    datePosted: map['date_created'] as String,
    initialWeightGrams: (map['initial_weight'] as num).toInt(),
    availableWeightGrams: (map['available_weight'] as num).toInt(),
    pricePerKgAmount: (map['price_per_kg'] as num).toInt(),
    totalPriceAmount: (map['total'] as num).toInt(),
    size: map['size'] as String,
    market: map['market'] as String,
    images: map['images'] == null || map['images'] == ''
        ? []
        : List<String>.from(jsonDecode(map['images'] as String)),
    species: SpeciesModel(
      id: map['species_id'] as String,
      name: map['species_name'] as String,
      image: map['species_image'] as String? ?? '',
    ),
    fisherId: map['fisher_id'] as String,
    status: map['status'] as String,
    observationId: map['observation_id'] as String? ?? '',
    locationName: map['location_name'] as String? ?? '',
    latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    meshSize: (map['mesh_size'] as num?)?.toDouble(),
    gearLength: (map['gear_length'] as num?)?.toDouble(),
    gearWidth: (map['gear_width'] as num?)?.toDouble(),
    gearNature: map['gear_nature'] as String?,
    waterDepth: (map['water_depth'] as num?)?.toDouble(),
    fishingTime: (map['fishing_time'] as num?)?.toDouble(),
    numberOfShrimps: (map['number_of_shrimps'] as num?)?.toInt(),
  );
}
