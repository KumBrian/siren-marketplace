// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpeciesApiModelImpl _$$SpeciesApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeciesApiModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      mediaReference: json['mediaReference'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$$SpeciesApiModelImplToJson(
        _$SpeciesApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mediaReference': instance.mediaReference,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'uid': instance.uid,
    };

_$SpeciesListResponseImpl _$$SpeciesListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeciesListResponseImpl(
      data: SpeciesListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SpeciesListResponseImplToJson(
        _$SpeciesListResponseImpl instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };

_$SpeciesListDataImpl _$$SpeciesListDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeciesListDataImpl(
      totalItems: (json['totalItems'] as num).toInt(),
      member: (json['member'] as List<dynamic>)
          .map((e) => SpeciesApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SpeciesListDataImplToJson(
        _$SpeciesListDataImpl instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'member': instance.member.map((e) => e.toJson()).toList(),
    };
