import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/data/repositories/offer_repository.dart';

/// Repository responsible for managing catch records and related market
/// operations.
///
/// This class sits above the local SQLite database layer but is structured
/// so that future migration to a remote API will not break callers.
/// The repository also performs automatic maintenance tasks such as:
/// - Updating expired catch statuses.
/// - Cleaning up catches that have exceeded their retention window.
/// - Notifying listeners of state changes through [TransactionNotifier].
class CatchRepository {
  /// Creates a new [CatchRepository] with the required dependencies.
  CatchRepository({
    required this.dbHelper,
    required this.offerRepository,
    required this.notifier,
  });

  /// Provides access to the underlying SQLite persistence layer.
  final DatabaseHelper dbHelper;

  /// Repository for fetching associated offer data.
  final OfferRepository offerRepository;

  /// Notifies listeners whenever catch-related operations mutate state.
  final TransactionNotifier notifier;

  // ---------------------------------------------------------------------------
  // CRUD OPERATIONS
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a catch record in the database.
  ///
  /// When this call is migrated to a backend API, it will likely map to a
  /// `POST /catches` or `PUT /catches/{id}` operation.
  Future<void> insertCatch(Catch catchModel) async {
    final db = await dbHelper.database;
    await db.insert(
      'catches',
      catchModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifier.notify();
  }

  /// Marks a catch as removed from the marketplace without deleting it.
  ///
  /// The catch remains stored in the database with its status set to
  /// [CatchStatus.removed]. Associated offers or orders are intentionally
  /// not deleted, preserving historical and relational integrity.
  Future<void> removeCatchFromMarketplace(String id) async {
    final db = await dbHelper.database;

    await db.update(
      'catches',
      {'status': CatchStatus.removed.name},
      where: 'catch_id = ?',
      whereArgs: [id],
    );
    notifier.notify();
  }

  /// Cleans up catches that have expired and exceeded the deletion grace period.
  ///
  /// A catch transitions to the "expired" state after 7 days.
  /// After an additional 1-day grace period, the catch is permanently removed.
  ///
  /// This method:
  /// - Finds all catches flagged as expired.
  /// - Parses their creation timestamps.
  /// - Deletes those older than 8 total days.
  Future<void> cleanUpExpiredCatches() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final expiredCatchMaps = await db.query(
      'catches',
      where: 'status = ?',
      whereArgs: [CatchStatus.expired.name],
    );

    final catchesToDelete = <String>[];

    for (final catchMap in expiredCatchMaps) {
      try {
        final dateCreatedString = catchMap['date_created'] as String;
        final dateCreated = DateTime.parse(dateCreatedString);
        final deletionDate = dateCreated.add(const Duration(days: 8));

        if (now.isAfter(deletionDate)) {
          catchesToDelete.add(catchMap['catch_id'] as String);
        }
      } catch (e) {
        debugPrint('Error parsing date for catch deletion: $e');
      }
    }

    if (catchesToDelete.isNotEmpty) {
      final placeholders = List.filled(catchesToDelete.length, '?').join(',');
      await db.delete(
        'catches',
        where: 'catch_id IN ($placeholders)',
        whereArgs: catchesToDelete,
      );
      debugPrint('Cleanup: Deleted ${catchesToDelete.length} expired catches.');
    }
    notifier.notify();
  }

  /// Updates the status of catches that should be marked as expired.
  ///
  /// A catch becomes expired when:
  /// - Its current status is `available`.
  /// - It was created more than 7 days ago.
  ///
  /// This ensures that market listings automatically cycle out after their
  /// defined lifetime without requiring manual cleanup.
  Future<void> updateExpiredStatuses() async {
    final db = await dbHelper.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final result = await db.rawUpdate(
      '''
      UPDATE catches
      SET status = ?
      WHERE status = ? AND date_created < ?
      ''',
      [
        CatchStatus.expired.name,
        CatchStatus.available.name,
        sevenDaysAgo.toIso8601String(),
      ],
    );

    if (result > 0) {
      debugPrint('Expiry Check: Updated $result catches to EXPIRED status.');
    }
    notifier.notify();
  }

  /// Retrieves raw catch maps belonging to a specific fisher.
  ///
  /// Prior to fetching, this method performs automatic maintenance:
  /// - Updates expired statuses.
  /// - Cleans up catches that are beyond their retention period.
  ///
  /// API equivalent could be:
  /// `GET /fisher/{id}/catches?include=offers`.
  Future<List<Map<String, dynamic>>> getCatchMapsByFisherId(
    String fisherId,
  ) async {
    await updateExpiredStatuses();
    await cleanUpExpiredCatches();
    return await dbHelper.getCatchMapsByFisherId(fisherId);
  }

  /// Retrieves all catch maps from the database, ordered by creation date.
  Future<List<Map<String, dynamic>>> getAllCatchMaps() async {
    final db = await dbHelper.database;
    return await db.query('catches', orderBy: 'date_created DESC');
  }

  /// Retrieves a single catch record by its unique identifier.
  Future<Map<String, dynamic>?> getCatchMapById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'catches',
      where: 'catch_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// Retrieves a fully hydrated [Catch] by its identifier, including offers.
  Future<Catch?> getCatchById(String id) async {
    final catchMap = await getCatchMapById(id);
    if (catchMap == null) return null;

    final offerMaps = await dbHelper.getOfferMapsByCatchId(id);
    final offers = offerMaps.map((m) => Offer.fromMap(m)).toList();

    return Catch.fromMap(catchMap).copyWith(offers: offers);
  }

  /// Updates an existing catch record.
  ///
  /// API version will map to `PATCH /catches/{id}`.
  Future<void> updateCatch(Catch catchModel) async {
    final db = await dbHelper.database;
    await db.update(
      'catches',
      catchModel.toMap(),
      where: 'catch_id = ?',
      whereArgs: [catchModel.id],
    );
    notifier.notify();
  }

  /// Permanently deletes a catch record by its identifier.
  ///
  /// Unlike [removeCatchFromMarketplace], this operation is destructive.
  Future<void> deleteCatch(String id) async {
    final db = await dbHelper.database;
    await db.delete('catches', where: 'catch_id = ?', whereArgs: [id]);
    notifier.notify();
  }

  // ---------------------------------------------------------------------------
  // FETCHES WITH HYDRATION
  // ---------------------------------------------------------------------------

  /// Retrieves all catches that belong to a specific fisher, including offers.
  ///
  /// This hydrates each returned [Catch] with its associated list of offers.
  Future<List<Catch>> getCatchesByFisherId(String fisherId) async {
    final catchMaps = await dbHelper.getCatchMapsByFisherId(fisherId);

    final catchesWithOffers = await Future.wait(
      catchMaps.map((cMap) async {
        final catchId = cMap['catch_id'] as String;
        final offerMaps = await dbHelper.getOfferMapsByCatchId(catchId);
        final offers = offerMaps.map((m) => Offer.fromMap(m)).toList();
        return Catch.fromMap(cMap).copyWith(offers: offers);
      }),
    );

    return catchesWithOffers;
  }

  /// Retrieves all catches currently available on the marketplace, with offers.
  ///
  /// Includes:
  /// - Expiration updates.
  /// - Expired catch cleanup.
  /// - Full hydration with offers.
  ///
  /// API version will map to `GET /market/catches?include=offers`.
  Future<List<Catch>> fetchMarketCatches() async {
    await updateExpiredStatuses();
    await cleanUpExpiredCatches();
    final db = await dbHelper.database;

    final catchMaps = await db.query(
      'catches',
      where: 'status = ?',
      whereArgs: [CatchStatus.available.name],
      orderBy: 'date_created DESC',
    );

    if (catchMaps.isEmpty) return [];

    final catches = catchMaps.map((m) => Catch.fromMap(m)).toList();
    final catchIds = catches.map((c) => c.id).toList();

    final offerMaps = await offerRepository.getOfferMapsByCatchIds(catchIds);

    final Map<String, List<Offer>> offersByCatch = {};
    for (final map in offerMaps) {
      final offer = Offer.fromMap(map);
      offersByCatch.putIfAbsent(offer.catchId, () => []).add(offer);
    }

    return catches
        .map((c) => c.copyWith(offers: offersByCatch[c.id] ?? []))
        .toList(growable: false);
  }
}
