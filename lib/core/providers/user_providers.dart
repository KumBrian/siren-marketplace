import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import '../services/connectivity_service.dart';

/// Provider to fetch a User by ID
final userProvider = FutureProvider.family<User?, String>((ref, id) async {
  final repository = sl<IUserRepository>();
  return repository.getById(id);
});

/// Provider to fetch a Buyer by ID (with automatic caching)
/// Used for loading buyer data in offer lists
final buyerByIdProvider = FutureProvider.family<User?, String>((
  ref,
  buyerId,
) async {
  final repository = sl<IUserRepository>();
  return repository.getById(buyerId);
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(
    sessionRepository: sl(),
    userRepository: sl(),
    authApiDataSource: sl(),
    tokenStorage: sl(),
    connectivityService: ref.read(connectivityServiceProvider),
  );
});

/// Provider for the currently logged-in user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  // Re-verify DI setup, previously it was sl<SessionService>().
  // Since we updated SessionService to need Ref driven deps (maybe), we should use provider.
  // But wait, SessionService is likely registered in DI (sl).
  // If we override it with specific params here, we should use the provider.
  return sessionService.getCurrentUser();
});
