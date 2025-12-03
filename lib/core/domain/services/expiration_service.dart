import '../repositories/i_catch_repository.dart';

/// Service handling catch expiration and cleanup logic
class ExpirationService {
  final ICatchRepository _catchRepository;

  ExpirationService({required ICatchRepository catchRepository})
    : _catchRepository = catchRepository;

  /// Process expired catches (mark as expired)
  Future<int> processExpirations() async {
    final availableCatches = await _catchRepository.getAvailableCatches();

    final expiredCatches = availableCatches
        .where((c) => c.isExpired)
        .map((c) => c.markAsExpired())
        .toList();

    if (expiredCatches.isNotEmpty) {
      await _catchRepository.updateBatch(expiredCatches);
    }

    return expiredCatches.length;
  }

  /// Clean up catches that have exceeded deletion grace period
  Future<int> cleanupExpiredCatches() async {
    final catches = await _catchRepository.getCatchesForDeletion();

    final catchesToDelete = catches
        .where((c) => c.shouldBeDeleted)
        .map((c) => c.id)
        .toList();

    if (catchesToDelete.isNotEmpty) {
      await _catchRepository.deleteBatch(catchesToDelete);
    }

    return catchesToDelete.length;
  }

  /// Run both expiration and cleanup
  Future<(int expired, int deleted)> runMaintenance() async {
    final expired = await processExpirations();
    final deleted = await cleanupExpiredCatches();
    return (expired, deleted);
  }
}
