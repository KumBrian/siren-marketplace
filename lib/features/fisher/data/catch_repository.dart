import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:sqflite/sqflite.dart';

import 'offer_repositories.dart';

class CatchRepository {
  final DatabaseHelper dbHelper;
  final OfferRepository offerRepository;
  final TransactionNotifier notifier;

  CatchRepository({
    required this.dbHelper,
    required this.offerRepository,
    required this.notifier,
  });

  // --- STANDARD CRUD OPERATIONS ---

  Future<void> insertCatch(Catch catchModel) async {
    final db = await dbHelper.database;
    await db.insert(
      'catches',
      catchModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifier.notify();
  }

  Future<void> removeCatchFromMarketplace(String id) async {
    final db = await dbHelper.database;

    await db.update(
      'catches',
      {'status': CatchStatus.removed.name}, // Use the new status field
      where: 'catch_id = ?',
      whereArgs: [id],
    );
    notifier.notify();

    // Important: We DO NOT delete related Offers or Orders here.
    // The Catch record itself remains in the DB, just hidden from the market.
  }

  Future<void> cleanUpExpiredCatches() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final oneDayInSeconds = 24 * 60 * 60; // 1 day in seconds

    // 1. Fetch all 'expired' catches
    final expiredCatchMaps = await db.query(
      'catches',
      where: 'status = ?',
      whereArgs: [CatchStatus.expired.name],
    );

    // 2. Determine which ones are older than 8 days (i.e., expired for > 1 day)
    final catchesToDelete = <String>[];

    for (final catchMap in expiredCatchMaps) {
      try {
        final dateCreatedString = catchMap['date_created'] as String;
        final dateCreated = DateTime.parse(dateCreatedString);

        // 7 days (the expiry period) + 1 day (the grace period before deletion) = 8 days
        final deletionDate = dateCreated.add(const Duration(days: 8));

        if (now.isAfter(deletionDate)) {
          catchesToDelete.add(catchMap['catch_id'] as String);
        }
      } catch (e) {
        // Handle cases where date_created is invalid
        debugPrint('Error parsing date for catch deletion: $e');
      }
    }

    // 3. Execute deletion for the identified catches
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

  Future<void> updateExpiredStatuses() async {
    final db = await dbHelper.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    // Find catches that are 'available' but are older than 7 days
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

  Future<List<Map<String, dynamic>>> getCatchMapsByFisherId(
    String fisherId,
  ) async {
    // 1. 🔑 Run the cleanup and status update *before* fetching data
    await updateExpiredStatuses();
    await cleanUpExpiredCatches();

    return await dbHelper.getCatchMapsByFisherId(fisherId);
  }

  Future<List<Map<String, dynamic>>> getAllCatchMaps() async {
    final db = await dbHelper.database;
    return await db.query('catches', orderBy: 'date_created DESC');
  }

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

  Future<Catch?> getCatchById(String id) async {
    final catchMap = await getCatchMapById(id);
    if (catchMap == null) return null;

    final offerMaps = await dbHelper.getOfferMapsByCatchId(id);
    final offers = offerMaps.map((m) => Offer.fromMap(m)).toList();

    return Catch.fromMap(catchMap).copyWith(offers: offers);
  }

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

  Future<void> deleteCatch(String id) async {
    final db = await dbHelper.database;
    await db.delete('catches', where: 'catch_id = ?', whereArgs: [id]);
    notifier.notify();
  }

  // --- FETCH BY FISHER ID ---

  Future<List<Catch>> getCatchesByFisherId(String fisherId) async {
    // Fetch raw catch maps from DB
    final catchMaps = await dbHelper.getCatchMapsByFisherId(fisherId);

    // Ensure we're working with Map<String, dynamic> here
    final catchesWithOffers = await Future.wait(
      catchMaps.map((cMap) async {
        final catchId = cMap['catch_id'] as String; // ✅ safe cast
        final offerMaps = await dbHelper.getOfferMapsByCatchId(catchId);
        final offers = offerMaps.map((m) => Offer.fromMap(m)).toList();
        return Catch.fromMap(cMap).copyWith(offers: offers);
      }),
    );

    return catchesWithOffers;
  }

  /// Fetches all catches currently available on the market with their offers
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
