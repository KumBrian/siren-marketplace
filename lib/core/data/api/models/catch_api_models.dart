import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/species_model.dart';
import 'auth_api_models.dart';

part 'catch_api_models.freezed.dart';
part 'catch_api_models.g.dart';

@freezed
class CatchApiModel with _$CatchApiModel {
  const factory CatchApiModel({
    required dynamic id,
    String? name,
    @JsonKey(name: 'initial_weight_grams') int? initialWeightGrams,
    @JsonKey(name: 'available_weight_grams') int? availableWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') int? pricePerKgAmount,
    @JsonKey(name: 'total_price_amount') int? totalPriceAmount,
    String? size,
    @Default([]) List<String> images,
    SpeciesModel? species,
    AccountApiModel? fisher,
    String? market,
    String? status, // available, sold, etc.
    @JsonKey(name: 'created_at') String? createdAt,
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
