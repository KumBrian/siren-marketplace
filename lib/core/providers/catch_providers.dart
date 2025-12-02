import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';

/// Provider to fetch a Catch by ID
final catchProvider = FutureProvider.family<Catch?, String>((ref, id) async {
  final repository = sl<ICatchRepository>();
  return repository.getById(id);
});

/// Provider to fetch a specific catch by ID (auto-dispose)
/// Used for catch details screen
final catchByIdProvider = FutureProvider.family.autoDispose<Catch?, String>((
  ref,
  catchId,
) async {
  final repository = sl<ICatchRepository>();
  return repository.getById(catchId);
});

/// Provider to fetch all available catches
final availableCatchesProvider = FutureProvider<List<Catch>>((ref) async {
  final repository = sl<ICatchRepository>();
  return repository.getAvailableCatches();
});

/// Provider to fetch catches for the current fisher user
/// Automatically refreshes when user changes
final fisherCatchesProvider = FutureProvider.autoDispose<List<Catch>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.currentRole != UserRole.fisher) return [];

  final repository = sl<ICatchRepository>();
  return repository.getByFisherId(user.id);
});
