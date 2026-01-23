import '../entities/user.dart';
import '../enums/user_role.dart';
import '../repositories/i_session_repository.dart';
import '../repositories/i_user_repository.dart';
import '../../data/sources/api/auth_api_data_source.dart';
import '../../data/storage/token_storage.dart';
import '../../data/mappers/account_api_mapper.dart';
import '../../services/connectivity_service.dart';

/// Service managing user session and role switching
class SessionService {
  final ISessionRepository _sessionRepository;
  // ignore: unused_field
  final IUserRepository _userRepository;
  final IAuthApiDataSource? _authApiDataSource;
  final TokenStorage? _tokenStorage;
  final ConnectivityService? _connectivityService;

  SessionService({
    required ISessionRepository sessionRepository,
    required IUserRepository userRepository,
    IAuthApiDataSource? authApiDataSource,
    TokenStorage? tokenStorage,
    ConnectivityService? connectivityService,
  }) : _sessionRepository = sessionRepository,
       _userRepository = userRepository,
       _authApiDataSource = authApiDataSource,
       _tokenStorage = tokenStorage,
       _connectivityService = connectivityService;

  /// Initialize session on app start
  Future<User?> initialize() async {
    return await _sessionRepository.getCurrentUser();
  }

  /// Get current user (verifying token if in API mode)
  Future<User?> getCurrentUser() async {
    final user = await _sessionRepository.getCurrentUser();

    // In API mode, verify we have a valid token
    if (user != null && _tokenStorage != null) {
      // Check connectivity first
      // If we are offline, assume the session is valid based on local cache
      bool isOnline = true;
      if (_connectivityService != null) {
        isOnline = await _connectivityService.hasConnection;
      }

      if (isOnline) {
        final hasToken = await _tokenStorage.isAuthenticated();
        if (!hasToken) {
          final token = await _tokenStorage.getAccessToken();
          if (token == null) {
            await logout();
            return null;
          }
        }
      } else {
        // Offline, skipping token validation
      }
    }

    return user;
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

    // Update user's current role locally
    final updatedUser = user.copyWith(currentRole: newRole);

    // Save to session
    await _sessionRepository.saveCurrentRole(newRole);
    await _sessionRepository.saveCurrentUser(updatedUser);
  }

  /// Login with email and password via API
  Future<User> loginWithApi(String email, String password) async {
    if (_authApiDataSource == null || _tokenStorage == null) {
      throw StateError('API authentication not configured');
    }

    // 1. Call API  authorize endpoint
    final authResponse = await _authApiDataSource.login(email, password);

    // Debug logging
    // Debug logging

    // 2. Store JWT token
    await _tokenStorage.saveToken(
      authResponse.token,
      userId: authResponse.id.toString(),
      expiry: authResponse.tokenExpireAt,
    );

    // Verify what was stored
    final storedExpiry = await _tokenStorage.getTokenExpiry();
    final isExpired = await _tokenStorage.isTokenExpired();

    // 3. Map account to User entity
    final user = AccountApiMapper.toDomain(authResponse.account);

    // 4. Save to session
    await _sessionRepository.saveCurrentUser(user);
    await _sessionRepository.saveCurrentRole(user.currentRole);

    return user;
  }

  /// Login user (for local/demo mode)
  Future<void> login(User user) async {
    await _sessionRepository.saveCurrentUser(user);
    await _sessionRepository.saveCurrentRole(user.currentRole);
  }

  /// Logout
  Future<void> logout() async {
    // 1. Call API logout if using API mode
    if (_authApiDataSource != null) {
      try {
        await _authApiDataSource.logout();
      } catch (e) {
        // Warning: API logout failed. Proceeding with local logout.
      }
    }

    // 2. Clear API token if using API mode
    if (_tokenStorage != null) {
      await _tokenStorage.clearTokens();
    }
    await _sessionRepository.clearSession();
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    return await _sessionRepository.isLoggedIn();
  }
}
