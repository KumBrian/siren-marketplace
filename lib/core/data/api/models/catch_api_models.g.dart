// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GearApiModelImpl _$$GearApiModelImplFromJson(Map<String, dynamic> json) =>
    _$GearApiModelImpl(
      id: json['id'],
      gearMeshSizeInFinger: (json['gear_mesh_size_in_finger'] as num?)
          ?.toDouble(),
      gearLengthInMeter: (json['gear_length_in_meter'] as num?)?.toDouble(),
      gearWidthInMeter: (json['gear_width_in_meter'] as num?)?.toDouble(),
      gearNature: json['gear_nature'] as String?,
      account: json['account'] == null
          ? null
          : AccountApiModel.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$$GearApiModelImplToJson(_$GearApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gear_mesh_size_in_finger': instance.gearMeshSizeInFinger,
      'gear_length_in_meter': instance.gearLengthInMeter,
      'gear_width_in_meter': instance.gearWidthInMeter,
      'gear_nature': instance.gearNature,
      'account': instance.account?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'uid': instance.uid,
    };

_$FishCatchImageApiModelImpl _$$FishCatchImageApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$FishCatchImageApiModelImpl(
  id: json['id'],
  fishCatch: json['fishCatch'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  uid: json['uid'] as String?,
);

Map<String, dynamic> _$$FishCatchImageApiModelImplToJson(
  _$FishCatchImageApiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fishCatch': instance.fishCatch,
  'imageUrl': instance.imageUrl,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'uid': instance.uid,
};

_$SpecieApiModelImpl _$$SpecieApiModelImplFromJson(Map<String, dynamic> json) =>
    _$SpecieApiModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$$SpecieApiModelImplToJson(
  _$SpecieApiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'uid': instance.uid,
};

_$CatchApiModelImpl _$$CatchApiModelImplFromJson(Map<String, dynamic> json) =>
    _$CatchApiModelImpl(
      id: json['id'],
      observationId: json['observationId'] as String?,
      waterDepthInMeter: (json['water_depth_in_meter'] as num?)?.toDouble(),
      fishingTimeInHour: (json['fishing_time_in_hour'] as num?)?.toDouble(),
      specie: json['specie'] == null
          ? null
          : SpecieApiModel.fromJson(json['specie'] as Map<String, dynamic>),
      estimatedWeightInGrams: (json['estimated_weight_in_grams'] as num?)
          ?.toDouble(),
      averageSizeInCm: (json['average_size_in_cm'] as num?)?.toDouble(),
      estimatedSize: (json['estimated_size'] as num?)?.toInt(),
      published: json['published'] as bool?,
      publishedWeightInGrams: (json['published_weight_in_grams'] as num?)
          ?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      publishedInMarketPlace: json['published_in_market_place'] as bool?,
      fishCatchImages:
          (json['fishCatchImages'] as List<dynamic>?)
              ?.map(
                (e) =>
                    FishCatchImageApiModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <FishCatchImageApiModel>[],
      note: json['note'] as String?,
      status: json['status'] as String?,
      gear: json['gear'] == null
          ? null
          : GearApiModel.fromJson(json['gear'] as Map<String, dynamic>),
      account: json['account'] == null
          ? null
          : AccountApiModel.fromJson(json['account'] as Map<String, dynamic>),
      obsSynced: json['obs_synced'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      uid: json['uid'] as String?,
      species: json['species'] == null
          ? null
          : SpeciesModel.fromJson(json['species'] as Map<String, dynamic>),
      name: json['name'] as String?,
      market: json['market'] as String?,
    );

Map<String, dynamic> _$$CatchApiModelImplToJson(
  _$CatchApiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'observationId': instance.observationId,
  'water_depth_in_meter': instance.waterDepthInMeter,
  'fishing_time_in_hour': instance.fishingTimeInHour,
  'specie': instance.specie?.toJson(),
  'estimated_weight_in_grams': instance.estimatedWeightInGrams,
  'average_size_in_cm': instance.averageSizeInCm,
  'estimated_size': instance.estimatedSize,
  'published': instance.published,
  'published_weight_in_grams': instance.publishedWeightInGrams,
  'price_per_kg': instance.pricePerKg,
  'final_price': instance.finalPrice,
  'published_in_market_place': instance.publishedInMarketPlace,
  'fishCatchImages': instance.fishCatchImages.map((e) => e.toJson()).toList(),
  'note': instance.note,
  'status': instance.status,
  'gear': instance.gear?.toJson(),
  'account': instance.account?.toJson(),
  'obs_synced': instance.obsSynced,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'location_name': instance.locationName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'uid': instance.uid,
  'species': instance.species?.toJson(),
  'name': instance.name,
  'market': instance.market,
};

_$CatchImageRequestImpl _$$CatchImageRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CatchImageRequestImpl(mediaUrl: json['mediaUrl'] as String);

Map<String, dynamic> _$$CatchImageRequestImplToJson(
  _$CatchImageRequestImpl instance,
) => <String, dynamic>{'mediaUrl': instance.mediaUrl};

_$CreateCatchRequestImpl _$$CreateCatchRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateCatchRequestImpl(
  specie: (json['specie'] as num).toInt(),
  gearMeshSizeInFinger: (json['gear_mesh_size_in_finger'] as num).toDouble(),
  gearLengthInMeter: (json['gear_length_in_meter'] as num).toDouble(),
  gearWidthInMeter: (json['gear_width_in_meter'] as num).toDouble(),
  gearNature: json['gear_nature'] as String,
  waterDepthInMeter: (json['water_depth_in_meter'] as num).toDouble(),
  fishingTimeInHour: (json['fishing_time_in_hour'] as num).toDouble(),
  estimatedWeightInGrams: (json['estimated_weight_in_grams'] as num).toDouble(),
  averageSizeInCm: (json['average_size_in_cm'] as num).toDouble(),
  estimatedSize: (json['estimated_size'] as num).toInt(),
  publishedWeightInGrams: (json['published_weight_in_grams'] as num).toDouble(),
  pricePerKg: (json['price_per_kg'] as num).toDouble(),
  finalPrice: (json['final_price'] as num).toDouble(),
  publishedInMarketPlace: json['published_in_market_place'] as bool,
  note: json['note'] as String?,
  images: (json['images'] as List<dynamic>)
      .map((e) => CatchImageRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  alpha: json['alpha'] as String?,
  size: json['size'] as String,
  dead: json['dead'] as bool,
  locationName: json['location_name'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  date: json['date'] as String,
  market: (json['market'] as num).toInt(),
  observationType: json['observationType'] as String?,
  patrol: json['patrol'] as String?,
  segment: json['segment'] as String?,
);

Map<String, dynamic> _$$CreateCatchRequestImplToJson(
  _$CreateCatchRequestImpl instance,
) => <String, dynamic>{
  'specie': instance.specie,
  'gear_mesh_size_in_finger': instance.gearMeshSizeInFinger,
  'gear_length_in_meter': instance.gearLengthInMeter,
  'gear_width_in_meter': instance.gearWidthInMeter,
  'gear_nature': instance.gearNature,
  'water_depth_in_meter': instance.waterDepthInMeter,
  'fishing_time_in_hour': instance.fishingTimeInHour,
  'estimated_weight_in_grams': instance.estimatedWeightInGrams,
  'average_size_in_cm': instance.averageSizeInCm,
  'estimated_size': instance.estimatedSize,
  'published_weight_in_grams': instance.publishedWeightInGrams,
  'price_per_kg': instance.pricePerKg,
  'final_price': instance.finalPrice,
  'published_in_market_place': instance.publishedInMarketPlace,
  'note': instance.note,
  'images': instance.images.map((e) => e.toJson()).toList(),
  'alpha': instance.alpha,
  'size': instance.size,
  'dead': instance.dead,
  'location_name': instance.locationName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'date': instance.date,
  'market': instance.market,
  'observationType': instance.observationType,
  'patrol': instance.patrol,
  'segment': instance.segment,
};

_$UpdateCatchResponseImpl _$$UpdateCatchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateCatchResponseImpl(
  fishCatch: CatchApiModel.fromJson(json['fishCatch'] as Map<String, dynamic>),
  product: json['product'],
);

Map<String, dynamic> _$$UpdateCatchResponseImplToJson(
  _$UpdateCatchResponseImpl instance,
) => <String, dynamic>{
  'fishCatch': instance.fishCatch.toJson(),
  'product': instance.product,
};
