import '../entities/user.dart';
import '../enums/user_role.dart';
import '../repositories/i_session_repository.dart';
import '../repositories/i_user_repository.dart';
import '../../data/sources/api/auth_api_data_source.dart';
import '../../data/storage/token_storage.dart';
import '../../data/mappers/account_api_mapper.dart';

/// Service managing user session and role switching
class SessionService {
  final ISessionRepository _sessionRepository;
  final IUserRepository _userRepository;
  final IAuthApiDataSource? _authApiDataSource;
  final TokenStorage? _tokenStorage;

  SessionService({
    required ISessionRepository sessionRepository,
    required IUserRepository userRepository,
    IAuthApiDataSource? authApiDataSource,
    TokenStorage? tokenStorage,
  }) : _sessionRepository = sessionRepository,
       _userRepository = userRepository,
       _authApiDataSource = authApiDataSource,
       _tokenStorage = tokenStorage;

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
    print(
      'LoginWithApi - Token received: ${authResponse.token.substring(0, 20)}...',
    );
    print('LoginWithApi - Token expiry: ${authResponse.tokenExpireAt}');
    print('LoginWithApi - Token issued at: ${authResponse.tokenIssuedAt}');
    print('LoginWithApi - Current time: ${DateTime.now()}');

    // 2. Store JWT token
    await _tokenStorage.saveToken(
      authResponse.token,
      userId: authResponse.id.toString(),
      expiry: authResponse.tokenExpireAt,
    );

    // Verify what was stored
    final storedExpiry = await _tokenStorage.getTokenExpiry();
    final isExpired = await _tokenStorage.isTokenExpired();
    print('LoginWithApi - Stored expiry: $storedExpiry');
    print('LoginWithApi - Is token expired: $isExpired');

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
    // Clear API token if using API mode
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
