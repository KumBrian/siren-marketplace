import 'package:freezed_annotation/freezed_annotation.dart';

part 'subgroup_api_models.freezed.dart';
part 'subgroup_api_models.g.dart';

/// Response wrapper for subgroups endpoint
@freezed
class SubgroupsResponseModel with _$SubgroupsResponseModel {
  const factory SubgroupsResponseModel({required SubgroupDataModel data}) =
      _SubgroupsResponseModel;

  factory SubgroupsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubgroupsResponseModelFromJson(json);
}

/// Data object containing subgroups array
@freezed
class SubgroupDataModel with _$SubgroupDataModel {
  const factory SubgroupDataModel({required List<SubgroupModel> subgroups}) =
      _SubgroupDataModel;

  factory SubgroupDataModel.fromJson(Map<String, dynamic> json) =>
      _$SubgroupDataModelFromJson(json);
}

/// Individual subgroup with name, description, and species
@freezed
class SubgroupModel with _$SubgroupModel {
  const factory SubgroupModel({
    required String name,
    required String description,
    required List<SubgroupSpeciesModel> species,
  }) = _SubgroupModel;

  factory SubgroupModel.fromJson(Map<String, dynamic> json) =>
      _$SubgroupModelFromJson(json);
}

/// Species within a subgroup
@freezed
class SubgroupSpeciesModel with _$SubgroupSpeciesModel {
  const factory SubgroupSpeciesModel({
    required int id,
    required String name,
    required String imageUrl,
  }) = _SubgroupSpeciesModel;

  factory SubgroupSpeciesModel.fromJson(Map<String, dynamic> json) =>
      _$SubgroupSpeciesModelFromJson(json);
}
