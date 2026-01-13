import 'package:equatable/equatable.dart';

/// Domain entity representing a device token for push notifications
class DeviceToken extends Equatable {
  final int id;
  final String token;
  final String platform;
  final String deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  const DeviceToken({
    required this.id,
    required this.token,
    required this.platform,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
  });

  @override
  List<Object?> get props => [
    id,
    token,
    platform,
    deviceId,
    createdAt,
    updatedAt,
    active,
  ];

  DeviceToken copyWith({
    int? id,
    String? token,
    String? platform,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
  }) {
    return DeviceToken(
      id: id ?? this.id,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
    );
  }
}
