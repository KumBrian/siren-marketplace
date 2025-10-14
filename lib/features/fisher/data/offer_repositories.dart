import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

class OfferRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // 1. INSERT: Inserts a full Offer object map into the 'offers' table
  Future<void> insertOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.insert(
      'offers',
      offer.toMap(), // Assumes Offer.toMap() is up-to-date and correct
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Retrieval Methods (Returning Raw Maps for Service Layer Assembly) ---

  // 2. QUERY BY CATCH ID (RAW MAPS): Retrieves all offer maps for a single Catch
  Future<List<Map<String, dynamic>>> getOfferMapsByCatch(String catchId) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'catch_id = ?',
      whereArgs: [catchId],
      orderBy: 'date_created DESC', // Assuming a date field for sorting
    );
  }

  // 3. QUERY BY CATCH IDS (RAW MAPS): Retrieves offer maps for a list of Catch IDs
  Future<List<Map<String, dynamic>>> getOfferMapsByCatchIds(
    List<String> catchIds,
  ) async {
    if (catchIds.isEmpty) return [];

    final db = await dbHelper.database;
    final placeholders = List.filled(catchIds.length, '?').join(',');

    return await db.query(
      'offers',
      where: 'catch_id IN ($placeholders)',
      whereArgs: catchIds,
      orderBy: 'date_created DESC',
    );
  }

  // 4. QUERY BY ID (RAW MAP): Retrieves a single offer map by its ID
  Future<Map<String, dynamic>?> getOfferMapById(String id) async {
    final db = await dbHelper.database;
    final data = await db.query(
      'offers',
      where: 'offer_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  // 🆕 NEW: For Fisher side (Received Offers)
  Future<List<Map<String, dynamic>>> getOfferMapsByFisherId(
    String fisherId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_created DESC',
    );
  }

  // 🆕 NEW: For Buyer side (Made Offers)
  Future<List<Map<String, dynamic>>> getOfferMapsByBuyerId(
    String buyerId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'date_created DESC',
    );
  }

  // Retrieves all offer maps. Required by the seeder to filter for accepted offers.
  Future<List<Map<String, dynamic>>> getAllOfferMaps() async {
    final db = await dbHelper.database;
    return await db.query('offers', orderBy: 'date_created DESC');
  }

  // Retrieves all offer maps filtered by status.
  Future<List<Map<String, dynamic>>> getOfferMapsByStatus(
    OfferStatus status,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date_created DESC',
    );
  }

  // Retrieves a single Offer model by ID. Useful for the service layer.
  Future<Offer?> getOfferById(String id) async {
    final map = await getOfferMapById(id);
    if (map == null) return null;

    return Offer.fromMap(map);
  }

  // --- Update/Delete Methods ---

  // 5. UPDATE: Updates an offer using its map representation
  Future<void> updateOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.update(
      'offers',
      offer.toMap(), // Assumes the entire map is written, including updates
      where: 'offer_id = ?',
      whereArgs: [offer.id],
    );
  }

  Future<List<Offer>> getOffersByCatchId(String catchId) async {
    final maps = await dbHelper.getOfferMapsByCatchId(catchId);
    return maps.map((m) => Offer.fromMap(m)).toList();
  }

  // 6. DELETE: Deletes an offer by ID
  Future<void> deleteOffer(String id) async {
    final db = await dbHelper.database;
    await db.delete('offers', where: 'offer_id = ?', whereArgs: [id]);
  }
}
