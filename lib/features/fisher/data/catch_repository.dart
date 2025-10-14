import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

import 'offer_repositories.dart';

class CatchRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final OfferRepository offerRepository = OfferRepository();

  // --- STANDARD CRUD OPERATIONS ---

  Future<void> insertCatch(Catch catchModel) async {
    final db = await dbHelper.database;
    await db.insert(
      'catches',
      catchModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<void> updateCatch(Catch catchModel) async {
    final db = await dbHelper.database;
    await db.update(
      'catches',
      catchModel.toMap(),
      where: 'catch_id = ?',
      whereArgs: [catchModel.id],
    );
  }

  Future<void> deleteCatch(String id) async {
    final db = await dbHelper.database;
    await db.delete('catches', where: 'catch_id = ?', whereArgs: [id]);
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

  Future<List<Map<String, dynamic>>> getCatchMapsByFisherId(
    String fisherId,
  ) async {
    return await dbHelper.getCatchMapsByFisherId(fisherId);
  }

  /// Fetches all catches currently available on the market with their offers
  Future<List<Catch>> fetchMarketCatches() async {
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
