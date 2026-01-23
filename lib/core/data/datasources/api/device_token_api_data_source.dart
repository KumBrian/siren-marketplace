import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/api/models/device_token_api_models.dart';

/// API data source for device token operations
class DeviceTokenApiDataSource {
  final ApiClient _client;

  DeviceTokenApiDataSource(this._client);

  /// Register a new device token with the backend
  Future<DeviceTokenResponse> registerDeviceToken(
    DeviceTokenRequest request,
  ) async {
    final response = await _client.post(
      '/device-tokens',
      data: request.toJson(),
    );

    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    return DeviceTokenResponse.fromJson(data);
  }

  /// Get a device token by ID
  Future<DeviceTokenResponse> getDeviceToken(int id) async {
    final response = await _client.get('/device-tokens/$id');

    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    return DeviceTokenResponse.fromJson(data);
  }

  /// Send a test notification to the user
  Future<bool> sendTestNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.notifyMe,
        data: {'title': title, 'body': body, 'data': data ?? {}},
      );

      dynamic responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        responseData = responseData['data'];
      }

      if (responseData is Map<String, dynamic>) {
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Toggle notifications for the account
  Future<bool> toggleNotifications(bool enabled) async {
    final response = await _client.post(
      ApiConfig.toggleNotifications,
      data: {'notificationEnabled': enabled},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
