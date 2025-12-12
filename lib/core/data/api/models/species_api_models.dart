import 'package:freezed_annotation/freezed_annotation.dart';

part 'species_api_models.freezed.dart';
part 'species_api_models.g.dart';

/// Species model from API
@freezed
class SpeciesApiModel with _$SpeciesApiModel {
  const factory SpeciesApiModel({
    required int id,
    required String name,
    @JsonKey(name: 'mediaReference') String? mediaReference,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    required String uid,
  }) = _SpeciesApiModel;

  factory SpeciesApiModel.fromJson(Map<String, dynamic> json) =>
      _$SpeciesApiModelFromJson(json);
}

/// API response for species list
@freezed
class SpeciesListResponse with _$SpeciesListResponse {
  const factory SpeciesListResponse({required SpeciesListData data}) =
      _SpeciesListResponse;

  factory SpeciesListResponse.fromJson(Map<String, dynamic> json) =>
      _$SpeciesListResponseFromJson(json);
}

@freezed
class SpeciesListData with _$SpeciesListData {
  const factory SpeciesListData({
    required int totalItems,
    required List<SpeciesApiModel> member,
  }) = _SpeciesListData;

  factory SpeciesListData.fromJson(Map<String, dynamic> json) =>
      _$SpeciesListDataFromJson(json);
}
