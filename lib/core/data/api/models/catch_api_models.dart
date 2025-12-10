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

@freezed
class CatchApiModel with _$CatchApiModel {
  const factory CatchApiModel({
    required dynamic id,
    @JsonKey(name: 'water_depth_in_meter') double? waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double? fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') double? estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') double? averageSizeInCm,
    @JsonKey(name: 'estimated_size') int? estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') double? publishedWeightInKg,
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
    String? uid,
    // Legacy fields for compatibility
    String? name,
    SpeciesModel? species,
    String? market,
  }) = _CatchApiModel;

  factory CatchApiModel.fromJson(Map<String, dynamic> json) =>
      _$CatchApiModelFromJson(json);
}

@freezed
class CreateCatchRequest with _$CreateCatchRequest {
  const factory CreateCatchRequest({
    required String name,
    @JsonKey(name: 'initial_weight_grams') required int initialWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') required int pricePerKgAmount,
    required String size,
    @JsonKey(name: 'species_id') required String speciesId,
    required String market,
    List<String>? images,
  }) = _CreateCatchRequest;

  factory CreateCatchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCatchRequestFromJson(json);
}
