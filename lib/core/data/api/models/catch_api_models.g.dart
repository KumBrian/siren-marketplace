// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatchApiModelImpl _$$CatchApiModelImplFromJson(Map<String, dynamic> json) =>
    _$CatchApiModelImpl(
      id: json['id'],
      name: json['name'] as String?,
      initialWeightGrams: (json['initial_weight_grams'] as num?)?.toInt(),
      availableWeightGrams: (json['available_weight_grams'] as num?)?.toInt(),
      pricePerKgAmount: (json['price_per_kg_amount'] as num?)?.toInt(),
      totalPriceAmount: (json['total_price_amount'] as num?)?.toInt(),
      size: json['size'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      species: json['species'] == null
          ? null
          : SpeciesModel.fromJson(json['species'] as Map<String, dynamic>),
      fisher: json['fisher'] == null
          ? null
          : AccountApiModel.fromJson(json['fisher'] as Map<String, dynamic>),
      market: json['market'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$CatchApiModelImplToJson(_$CatchApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'initial_weight_grams': instance.initialWeightGrams,
      'available_weight_grams': instance.availableWeightGrams,
      'price_per_kg_amount': instance.pricePerKgAmount,
      'total_price_amount': instance.totalPriceAmount,
      'size': instance.size,
      'images': instance.images,
      'species': instance.species,
      'fisher': instance.fisher,
      'market': instance.market,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

_$CreateCatchRequestImpl _$$CreateCatchRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateCatchRequestImpl(
  name: json['name'] as String,
  initialWeightGrams: (json['initial_weight_grams'] as num).toInt(),
  pricePerKgAmount: (json['price_per_kg_amount'] as num).toInt(),
  size: json['size'] as String,
  speciesId: json['species_id'] as String,
  market: json['market'] as String,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$CreateCatchRequestImplToJson(
  _$CreateCatchRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'initial_weight_grams': instance.initialWeightGrams,
  'price_per_kg_amount': instance.pricePerKgAmount,
  'size': instance.size,
  'species_id': instance.speciesId,
  'market': instance.market,
  'images': instance.images,
};
