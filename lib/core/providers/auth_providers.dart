import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../di/injector.dart';
import '../data/storage/token_storage.dart';

/// Provider that checks if the user is authenticated
/// In API mode: checks if a valid token exists
/// In Demo/Local mode: always returns true (no authentication needed)
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  // In demo/local mode, always consider the user "authenticated"
  // since we don't need real authentication
  if (!AppConfig.isApiMode) {
    return true;
  }

  // In API mode, check if we have a valid token
  final tokenStorage = sl<TokenStorage>();
  return await tokenStorage.isAuthenticated();
});
