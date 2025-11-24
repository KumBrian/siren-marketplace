import '../entities/user.dart';
import '../enums/user_role.dart';

/// Repository for managing user session and authentication state
abstract class ISessionRepository {
  /// Get currently logged in user
  Future<User?> getCurrentUser();

  /// Get current user's active role
  Future<UserRole?> getCurrentRole();

  /// Save current user
  Future<void> saveCurrentUser(User user);

  /// Save current role
  Future<void> saveCurrentRole(UserRole role);

  /// Clear session (logout)
  Future<void> clearSession();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
