import '../entities/catch.dart';
import '../enums/catch_status.dart';

abstract class ICatchRepository {
  /// Create a new catch
  Future<String> create(Catch catchItem);

  /// Get catch by ID
  Future<Catch?> getById(String catchId);

  /// Get all catches for a fisher
  Future<List<Catch>> getByFisherId(String fisherId);

  /// Get all available catches on the marketplace
  Future<List<Catch>> getAvailableCatches();

  /// Get catches by status
  Future<List<Catch>> getByStatus(CatchStatus status);

  /// Get catches that have expired
  Future<List<Catch>> getExpiredCatches();

  /// Get catches that should be deleted
  Future<List<Catch>> getCatchesForDeletion();

  /// Update catch
  Future<void> update(Catch catchItem);

  /// Delete catch
  Future<void> delete(String catchId);

  /// Batch update catches
  Future<void> updateBatch(List<Catch> catches);

  /// Batch delete catches
  Future<void> deleteBatch(List<String> catchIds);
}
