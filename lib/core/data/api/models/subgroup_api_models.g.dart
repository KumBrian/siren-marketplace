// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subgroup_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubgroupsResponseModelImpl _$$SubgroupsResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubgroupsResponseModelImpl(
      data: SubgroupDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SubgroupsResponseModelImplToJson(
        _$SubgroupsResponseModelImpl instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };

_$SubgroupDataModelImpl _$$SubgroupDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubgroupDataModelImpl(
      subgroups: (json['subgroups'] as List<dynamic>)
          .map((e) => SubgroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SubgroupDataModelImplToJson(
        _$SubgroupDataModelImpl instance) =>
    <String, dynamic>{
      'subgroups': instance.subgroups.map((e) => e.toJson()).toList(),
    };

_$SubgroupModelImpl _$$SubgroupModelImplFromJson(Map<String, dynamic> json) =>
    _$SubgroupModelImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      species: (json['species'] as List<dynamic>)
          .map((e) => SubgroupSpeciesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SubgroupModelImplToJson(_$SubgroupModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'species': instance.species.map((e) => e.toJson()).toList(),
    };

_$SubgroupSpeciesModelImpl _$$SubgroupSpeciesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubgroupSpeciesModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$$SubgroupSpeciesModelImplToJson(
        _$SubgroupSpeciesModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
