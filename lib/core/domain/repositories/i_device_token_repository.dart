import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/domain/entities/device_token.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

/// Repository interface for device token operations
abstract class IDeviceTokenRepository {
  /// Register a device token with the backend
  Future<Either<Failure, DeviceToken>> registerDeviceToken({
    required String token,
    required String platform,
    required String deviceId,
  });

  /// Get a device token by ID
  Future<Either<Failure, DeviceToken>> getDeviceToken(int id);

  /// Send a test notification
  Future<Either<Failure, bool>> sendTestNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}
