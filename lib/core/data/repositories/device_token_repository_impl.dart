import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/data/api/api_exception.dart';
import 'package:siren_marketplace/core/data/api/models/device_token_api_models.dart';
import 'package:siren_marketplace/core/data/datasources/api/device_token_api_data_source.dart';
import 'package:siren_marketplace/core/domain/entities/device_token.dart';
import 'package:siren_marketplace/core/domain/repositories/i_device_token_repository.dart';
import 'package:siren_marketplace/core/network/api_result.dart';

/// Implementation of [IDeviceTokenRepository]
class DeviceTokenRepositoryImpl implements IDeviceTokenRepository {
  final DeviceTokenApiDataSource _dataSource;

  DeviceTokenRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, DeviceToken>> registerDeviceToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    try {
      final request = DeviceTokenRequest(
        token: token,
        platform: platform,
        deviceId: deviceId,
      );

      final response = await _dataSource.registerDeviceToken(request);
      return Right(_mapResponseToEntity(response));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to register device token: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceToken>> getDeviceToken(int id) async {
    try {
      final response = await _dataSource.getDeviceToken(id);
      return Right(_mapResponseToEntity(response));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get device token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTestNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final success = await _dataSource.sendTestNotification(
        title: title,
        body: body,
        data: data,
      );
      return Right(success);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to send test notification: $e'),
      );
    }
  }

  DeviceToken _mapResponseToEntity(DeviceTokenResponse response) {
    return DeviceToken(
      id: response.id,
      token: response.token,
      platform: response.platform,
      deviceId: response.deviceId,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      active: response.active,
    );
  }

  @override
  Future<Either<Failure, bool>> toggleNotifications(bool enabled) async {
    try {
      final success = await _dataSource.toggleNotifications(enabled);
      return Right(success);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle notifications: $e'));
    }
  }
}
