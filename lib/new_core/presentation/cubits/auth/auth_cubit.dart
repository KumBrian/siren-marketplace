import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/services/session_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SessionService _sessionService;

  AuthCubit({SessionService? sessionService})
    : _sessionService = sessionService ?? DI().sessionService,
      super(const AuthInitial());

  /// Initialize auth state on app start
  Future<void> initialize() async {
    emit(const AuthLoading());
    try {
      final user = await _sessionService.getCurrentUser();
      final role = await _sessionService.getCurrentRole();

      if (user != null && role != null) {
        emit(AuthAuthenticated(user: user, currentRole: role));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to initialize session: $e'));
    }
  }

  /// Login with a specific role and user
  Future<void> loginWithRole({
    required String userId,
    required UserRole role,
  }) async {
    emit(const AuthLoading());
    try {
      // Get user from repository
      final userRepo = DI().userRepository;
      final user = await userRepo.getById(userId);

      if (user == null) {
        emit(const AuthError('User not found'));
        return;
      }

      // Update user's current role
      final updatedUser = user.copyWith(currentRole: role);
      await userRepo.update(updatedUser);

      // Save to session
      await _sessionService.login(updatedUser);

      emit(AuthAuthenticated(user: updatedUser, currentRole: role));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  /// Switch user role (Fisher ↔ Buyer)
  Future<void> switchRole(UserRole newRole) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('No user logged in'));
      return;
    }

    emit(const AuthLoading());
    try {
      await _sessionService.switchRole(newRole);

      final updatedUser = currentState.user.copyWith(currentRole: newRole);
      emit(AuthAuthenticated(user: updatedUser, currentRole: newRole));
    } catch (e) {
      // Rollback to previous state
      emit(currentState);
      emit(AuthError('Failed to switch role: $e'));
    }
  }

  /// Update user profile
  Future<void> updateProfile(User updatedUser) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthError('No user logged in'));
      return;
    }

    try {
      final userRepo = DI().userRepository;
      await userRepo.update(updatedUser);
      await _sessionService.login(updatedUser);

      emit(
        AuthAuthenticated(
          user: updatedUser,
          currentRole: currentState.currentRole,
        ),
      );
    } catch (e) {
      emit(AuthError('Failed to update profile: $e'));
      emit(currentState); // Rollback
    }
  }

  /// Logout
  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _sessionService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: $e'));
    }
  }

  /// Get current user (helper method)
  User? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Get current role (helper method)
  UserRole? get currentRole {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.currentRole;
    }
    return null;
  }

  /// Check if user is logged in
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Check if current role is fisher
  bool get isFisher => isAuthenticated && currentRole == UserRole.fisher;

  /// Check if current role is buyer
  bool get isBuyer => isAuthenticated && currentRole == UserRole.buyer;
}
