import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';

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

/// Provider for the currently logged-in user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final sessionService = sl<SessionService>();
  return sessionService.getCurrentUser();
});
