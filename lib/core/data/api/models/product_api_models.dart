import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_api_models.freezed.dart';
part 'product_api_models.g.dart';

@freezed
class ProductSpeciesApiModel with _$ProductSpeciesApiModel {
  const factory ProductSpeciesApiModel({
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
    String? name,
    String? image,
  }) = _ProductSpeciesApiModel;

  factory ProductSpeciesApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductSpeciesApiModelFromJson(json);
}

@freezed
class ProductMarketApiModel with _$ProductMarketApiModel {
  const factory ProductMarketApiModel({
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  }) = _ProductMarketApiModel;

  factory ProductMarketApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductMarketApiModelFromJson(json);
}

@freezed
class ProductAccountApiModel with _$ProductAccountApiModel {
  const factory ProductAccountApiModel({
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  }) = _ProductAccountApiModel;

  factory ProductAccountApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductAccountApiModelFromJson(json);
}

@freezed
class ProductApiModel with _$ProductApiModel {
  const factory ProductApiModel({
    required dynamic id,
    String? name,
    ProductMarketApiModel? market,
    String? status,
    String? rejectReason,
    @JsonKey(name: 'price_per_kg') double? pricePerKg,
    @JsonKey(name: 'final_price') double? finalPrice,
    @JsonKey(name: 'published_weight_in_grams') double? publishedWeightInGrams,
    @JsonKey(name: 'expire_at') String? expireAt,
    @JsonKey(name: 'location_name') String? locationName,
    double? latitude,
    double? longitude,
    String? size,
    @JsonKey(name: 'date_posted') String? datePosted,
    bool? isSold,
    String? soldAt,
    @JsonKey(name: 'initial_weight') double? initialWeight,
    @JsonKey(name: 'available_weight') double? availableWeight,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
    double? gearMeshSizeInFinger,
    double? gearLengthInMeter,
    double? gearWidthInMeter,
    String? gearNature,
    ProductSpeciesApiModel? specie,
    ProductAccountApiModel? account,
    @Default([]) List<String> images,
  }) = _ProductApiModel;

  factory ProductApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductApiModelFromJson(json);
}
