// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTokenRequest _$DeviceTokenRequestFromJson(Map<String, dynamic> json) =>
    DeviceTokenRequest(
      token: json['token'] as String,
      platform: json['platform'] as String,
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$DeviceTokenRequestToJson(DeviceTokenRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
    };

DeviceTokenResponse _$DeviceTokenResponseFromJson(Map<String, dynamic> json) =>
    DeviceTokenResponse(
      id: (json['id'] as num).toInt(),
      token: json['token'] as String,
      platform: json['platform'] as String,
      deviceId: json['deviceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
    );

Map<String, dynamic> _$DeviceTokenResponseToJson(
        DeviceTokenResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'active': instance.active,
    };
