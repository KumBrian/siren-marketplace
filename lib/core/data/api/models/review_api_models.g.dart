// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewApiRequestImpl _$$ReviewApiRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ReviewApiRequestImpl(
      saleOrder: (json['saleOrder'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
      message: json['message'] as String,
      published: json['published'] as bool,
    );

Map<String, dynamic> _$$ReviewApiRequestImplToJson(
        _$ReviewApiRequestImpl instance) =>
    <String, dynamic>{
      'saleOrder': instance.saleOrder,
      'rate': instance.rate,
      'message': instance.message,
      'published': instance.published,
    };

_$ReviewApiResponseImpl _$$ReviewApiResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReviewApiResponseImpl(
      id: json['id'],
      rate: (json['rate'] as num).toDouble(),
      message: json['message'] as String,
      published: json['published'] as bool,
      saleOrder: json['sale_order'],
      reviewer: json['reviewer'] == null
          ? null
          : AccountApiModel.fromJson(json['reviewer'] as Map<String, dynamic>),
      reviewedAccount: json['reviewedAccount'] == null
          ? null
          : AccountApiModel.fromJson(
              json['reviewedAccount'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$$ReviewApiResponseImplToJson(
        _$ReviewApiResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rate': instance.rate,
      'message': instance.message,
      'published': instance.published,
      'sale_order': instance.saleOrder,
      'reviewer': instance.reviewer?.toJson(),
      'reviewedAccount': instance.reviewedAccount?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
      'uid': instance.uid,
    };
