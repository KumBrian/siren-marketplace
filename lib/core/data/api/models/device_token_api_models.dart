import 'package:json_annotation/json_annotation.dart';

part 'device_token_api_models.g.dart';

/// Request model for registering a device token
@JsonSerializable()
class DeviceTokenRequest {
  final String token;
  final String platform;
  final String deviceId;

  DeviceTokenRequest({
    required this.token,
    required this.platform,
    required this.deviceId,
  });

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenRequestToJson(this);
}

/// Response model for device token API
@JsonSerializable()
class DeviceTokenResponse {
  final int id;
  final String token;
  final String platform;
  final String deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  DeviceTokenResponse({
    required this.id,
    required this.token,
    required this.platform,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenResponseToJson(this);
}
