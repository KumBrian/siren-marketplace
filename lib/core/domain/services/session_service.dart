import '../entities/user.dart';
import '../enums/user_role.dart';
import '../repositories/i_session_repository.dart';
import '../repositories/i_user_repository.dart';

/// Service managing user session and role switching
class SessionService {
  final ISessionRepository _sessionRepository;
  final IUserRepository _userRepository;

  SessionService({
    required ISessionRepository sessionRepository,
    required IUserRepository userRepository,
  }) : _sessionRepository = sessionRepository,
       _userRepository = userRepository;

  /// Initialize session on app start
  Future<User?> initialize() async {
    return await _sessionRepository.getCurrentUser();
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    return await _sessionRepository.getCurrentUser();
  }

  /// Get current role
  Future<UserRole?> getCurrentRole() async {
    return await _sessionRepository.getCurrentRole();
  }

  /// Switch user role
  Future<void> switchRole(UserRole newRole) async {
    final user = await _sessionRepository.getCurrentUser();
    if (user == null) {
      throw StateError('No user logged in');
    }

    // Update user's current role
    final updatedUser = user.copyWith(currentRole: newRole);
    await _userRepository.update(updatedUser);

    // Save to session
    await _sessionRepository.saveCurrentRole(newRole);
    await _sessionRepository.saveCurrentUser(updatedUser);
  }

  /// Login user (for future API integration)
  Future<void> login(User user) async {
    await _sessionRepository.saveCurrentUser(user);
    await _sessionRepository.saveCurrentRole(user.currentRole);
  }

  /// Logout
  Future<void> logout() async {
    await _sessionRepository.clearSession();
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    return await _sessionRepository.isLoggedIn();
  }
}
