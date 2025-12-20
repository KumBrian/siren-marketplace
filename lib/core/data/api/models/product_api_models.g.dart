// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductSpeciesApiModelImpl _$$ProductSpeciesApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductSpeciesApiModelImpl(
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
  uid: json['uid'] as String?,
  name: json['name'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$$ProductSpeciesApiModelImplToJson(
  _$ProductSpeciesApiModelImpl instance,
) => <String, dynamic>{
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'uid': instance.uid,
  'name': instance.name,
  'image': instance.image,
};

_$ProductMarketApiModelImpl _$$ProductMarketApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductMarketApiModelImpl(
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
  uid: json['uid'] as String?,
);

Map<String, dynamic> _$$ProductMarketApiModelImplToJson(
  _$ProductMarketApiModelImpl instance,
) => <String, dynamic>{
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'uid': instance.uid,
};

_$ProductAccountApiModelImpl _$$ProductAccountApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductAccountApiModelImpl(
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
  uid: json['uid'] as String?,
);

Map<String, dynamic> _$$ProductAccountApiModelImplToJson(
  _$ProductAccountApiModelImpl instance,
) => <String, dynamic>{
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'uid': instance.uid,
};

_$ProductApiModelImpl _$$ProductApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductApiModelImpl(
  id: json['id'],
  name: json['name'] as String?,
  market: json['market'] == null
      ? null
      : ProductMarketApiModel.fromJson(json['market'] as Map<String, dynamic>),
  status: json['status'] as String?,
  rejectReason: json['rejectReason'] as String?,
  pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
  finalPrice: (json['final_price'] as num?)?.toDouble(),
  publishedWeightInGrams: (json['published_weight_in_grams'] as num?)
      ?.toDouble(),
  expireAt: json['expire_at'] as String?,
  locationName: json['location_name'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  size: json['size'] as String?,
  datePosted: json['date_posted'] as String?,
  isSold: json['isSold'] as bool?,
  soldAt: json['soldAt'] as String?,
  initialWeight: (json['initial_weight'] as num?)?.toDouble(),
  availableWeight: (json['available_weight'] as num?)?.toDouble(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
  uid: json['uid'] as String?,
  gearMeshSizeInFinger: (json['gearMeshSizeInFinger'] as num?)?.toDouble(),
  gearLengthInMeter: (json['gearLengthInMeter'] as num?)?.toDouble(),
  gearWidthInMeter: (json['gearWidthInMeter'] as num?)?.toDouble(),
  gearNature: json['gearNature'] as String?,
  specie: json['specie'] == null
      ? null
      : ProductSpeciesApiModel.fromJson(json['specie'] as Map<String, dynamic>),
  account: json['account'] == null
      ? null
      : ProductAccountApiModel.fromJson(
          json['account'] as Map<String, dynamic>,
        ),
  offersCount: (json['offers_count'] as num?)?.toInt() ?? 0,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$ProductApiModelImplToJson(
  _$ProductApiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'market': instance.market?.toJson(),
  'status': instance.status,
  'rejectReason': instance.rejectReason,
  'price_per_kg': instance.pricePerKg,
  'final_price': instance.finalPrice,
  'published_weight_in_grams': instance.publishedWeightInGrams,
  'expire_at': instance.expireAt,
  'location_name': instance.locationName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'size': instance.size,
  'date_posted': instance.datePosted,
  'isSold': instance.isSold,
  'soldAt': instance.soldAt,
  'initial_weight': instance.initialWeight,
  'available_weight': instance.availableWeight,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
  'uid': instance.uid,
  'gearMeshSizeInFinger': instance.gearMeshSizeInFinger,
  'gearLengthInMeter': instance.gearLengthInMeter,
  'gearWidthInMeter': instance.gearWidthInMeter,
  'gearNature': instance.gearNature,
  'specie': instance.specie?.toJson(),
  'account': instance.account?.toJson(),
  'offers_count': instance.offersCount,
  'images': instance.images,
};
