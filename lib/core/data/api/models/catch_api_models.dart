import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/species_model.dart';
import 'auth_api_models.dart';

part 'catch_api_models.freezed.dart';
part 'catch_api_models.g.dart';

/// Gear model from API
@freezed
class GearApiModel with _$GearApiModel {
  const factory GearApiModel({
    required dynamic id,
    @JsonKey(name: 'gear_mesh_size_in_finger') double? gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') double? gearLengthInMeter,
    @JsonKey(name: 'gear_nature') String? gearNature,
    AccountApiModel? account,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  }) = _GearApiModel;

  factory GearApiModel.fromJson(Map<String, dynamic> json) =>
      _$GearApiModelFromJson(json);
}

/// Fish catch image model from API
@freezed
class FishCatchImageApiModel with _$FishCatchImageApiModel {
  const factory FishCatchImageApiModel({
    required dynamic id,
    String? fishCatch,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  }) = _FishCatchImageApiModel;

  factory FishCatchImageApiModel.fromJson(Map<String, dynamic> json) =>
      _$FishCatchImageApiModelFromJson(json);
}

/// Species reference from API (simplified - only uid)
@freezed
class SpecieApiModel with _$SpecieApiModel {
  const factory SpecieApiModel({
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    required String uid,
  }) = _SpecieApiModel;

  factory SpecieApiModel.fromJson(Map<String, dynamic> json) =>
      _$SpecieApiModelFromJson(json);
}

@freezed
class CatchApiModel with _$CatchApiModel {
  const factory CatchApiModel({
    required dynamic id,
    String? observationId,
    @JsonKey(name: 'water_depth_in_meter') double? waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double? fishingTimeInHour,
    SpecieApiModel? specie,
    @JsonKey(name: 'estimated_weight_in_grams') double? estimatedWeightInGrams,
    @JsonKey(name: 'average_size_in_cm') double? averageSizeInCm,
    @JsonKey(name: 'estimated_size') int? estimatedSize,
    bool? published,
    @JsonKey(name: 'published_weight_in_grams') double? publishedWeightInGrams,
    @JsonKey(name: 'price_per_kg') double? pricePerKg,
    @JsonKey(name: 'final_price') double? finalPrice,
    @JsonKey(name: 'published_in_market_place') bool? publishedInMarketPlace,
    @JsonKey(name: 'fishCatchImages')
    @Default(<FishCatchImageApiModel>[])
    List<FishCatchImageApiModel> fishCatchImages,
    String? note,
    String? status,
    GearApiModel? gear,
    AccountApiModel? account, // The fisher
    @JsonKey(name: 'obs_synced') bool? obsSynced,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
    // Legacy fields for compatibility with old cached data
    @Deprecated('Use specie.uid instead') SpeciesModel? species,
    @Deprecated('Backend no longer sends these') String? name,
    @Deprecated('Backend no longer sends these') String? market,
  }) = _CatchApiModel;

  factory CatchApiModel.fromJson(Map<String, dynamic> json) =>
      _$CatchApiModelFromJson(json);
}

/// Image object for catch creation
@freezed
class CatchImageRequest with _$CatchImageRequest {
  const factory CatchImageRequest({required String mediaUrl}) =
      _CatchImageRequest;

  factory CatchImageRequest.fromJson(Map<String, dynamic> json) =>
      _$CatchImageRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateCatchRequest with _$CreateCatchRequest {
  const factory CreateCatchRequest({
    required String specie,
    required String subgroup,
    @JsonKey(name: 'gear_mesh_size_in_finger')
    required double gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') required double gearLengthInMeter,
    @JsonKey(name: 'gear_nature') required String gearNature,
    @JsonKey(name: 'water_depth_in_meter') required double waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') required double fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_grams')
    required double estimatedWeightInGrams,
    @JsonKey(name: 'average_size_in_cm') required double averageSizeInCm,
    @JsonKey(name: 'estimated_size') required int estimatedSize,
    @JsonKey(name: 'published_weight_in_grams')
    required double publishedWeightInGrams,
    @JsonKey(name: 'price_per_kg') required double pricePerKg,
    @JsonKey(name: 'final_price') required double finalPrice,
    @JsonKey(name: 'published_in_market_place')
    required bool publishedInMarketPlace,
    String? note,
    required List<CatchImageRequest> images,
    String? alpha,
    required bool dead,
    required double coordX,
    required double coordY,
    required String date,
    required int market,
    String? observationType,
    String? patrol,
    String? segment,
  }) = _CreateCatchRequest;

  factory CreateCatchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCatchRequestFromJson(json);
}
