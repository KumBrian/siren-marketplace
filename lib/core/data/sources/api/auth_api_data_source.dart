import '../../api/api_client.dart';
import '../../api/api_config.dart';
import '../../api/models/auth_api_models.dart';

/// Interface for authentication API data source
abstract class IAuthApiDataSource {
  Future<AuthorizeResponse> login(String email, String password);
  Future<AccountApiModel> getMyProfile();
  Future<void> logout();
  Future<AuthorizeResponse> authenticate();
  Future<String> refreshToken();
}

/// Implementation of authentication API data source
class AuthApiDataSource implements IAuthApiDataSource {
  final ApiClient _client;

  AuthApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<AuthorizeResponse> login(String email, String password) async {
    final response = await _client.post(
      ApiConfig.login,
      data: AuthorizeRequest(login: email, password: password).toJson(),
    );

    return AuthorizeResponse.fromJson(response.data['data']);
  }

  @override
  Future<AccountApiModel> getMyProfile() async {
    final response = await _client.get(ApiConfig.myProfile);
    return AccountApiModel.fromJson(response.data['data']);
  }

  @override
  Future<void> logout() async {
    await _client.delete(ApiConfig.logout);
  }

  @override
  Future<AuthorizeResponse> authenticate() async {
    final response = await _client.post(ApiConfig.authenticate, data: {});
    return AuthorizeResponse.fromJson(response.data['data']);
  }

  @override
  Future<String> refreshToken() async {
    final response = await _client.post(ApiConfig.tokenRefresh);
    return response.data['data']['token'] as String;
  }
}
