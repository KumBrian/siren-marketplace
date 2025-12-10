// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderApiModelImpl _$$OrderApiModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderApiModelImpl(
      id: json['id'],
      review: json['review'],
      orderNumber: json['orderNumber'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      status: json['status'] as String?,
      completed: json['completed'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$$OrderApiModelImplToJson(_$OrderApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'review': instance.review,
      'orderNumber': instance.orderNumber,
      'cancellationReason': instance.cancellationReason,
      'status': instance.status,
      'completed': instance.completed,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'uid': instance.uid,
    };
