import 'dart:convert';

import 'species_model.dart';

class CatchModel {
  final String id;
  final String name;
  final String datePosted; // ISO8601 string
  final int initialWeightGrams;
  final int availableWeightGrams;
  final int pricePerKgAmount; // in smallest currency unit
  final int totalPriceAmount; // in smallest currency unit
  final String size;
  final String market;
  final List<String> images;
  final SpeciesModel species;
  final String fisherId;
  final String status; // 'available', 'soldOut', 'expired', 'removed'

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
    'fisher_id': fisherId,
    'status': status,
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
    ),
    fisherId: map['fisher_id'] as String,
    status: map['status'] as String,
  );
}
