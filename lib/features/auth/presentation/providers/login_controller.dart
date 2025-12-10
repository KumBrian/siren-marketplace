import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/services/session_service.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/user_providers.dart';

/// Controller for handling login authentication
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state to load
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      state = AsyncError(
        Exception('Email and password are required'),
        StackTrace.current,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      state = AsyncError(
        Exception('Please enter a valid email address'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sessionService = sl<SessionService>();

      // Call API login
      await sessionService.loginWithApi(email, password);

      // Invalidate auth provider to trigger re-check
      ref.invalidate(isAuthenticatedProvider);

      // Refresh current user provider
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
    });
  }

  /// Simple email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );
