import 'package:siren_marketplace/core/data/api/api_client.dart';
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
}
