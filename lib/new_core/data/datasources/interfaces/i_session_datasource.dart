import '../../models/user_model.dart';

abstract class ISessionDataSource {
  Future<UserModel?> getCurrentUser();

  Future<String?> getCurrentRole();

  Future<void> saveCurrentUser(UserModel user);

  Future<void> saveCurrentRole(String role);

  Future<void> clearSession();

  Future<bool> isLoggedIn();
}
