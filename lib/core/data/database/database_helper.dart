import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "SirenMarketplaceDB.db";
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- USERS ---
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_url TEXT,
        rating REAL,
        review_count INTEGER,
        role TEXT NOT NULL
      )
    ''');

    // --- CATCHES ---
    await db.execute('''
      CREATE TABLE catches (
        catch_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date_created TEXT NOT NULL,
        initial_weight REAL NOT NULL,
        available_weight REAL NOT NULL,
        price_per_kg REAL NOT NULL,
        total REAL NOT NULL,
        size TEXT,
        market TEXT,
        species_id TEXT NOT NULL,
        species_name TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        images TEXT,
        status TEXT NOT NULL
      )
    ''');

    // --- OFFERS ---
    await db.execute('''
      CREATE TABLE offers (
        offer_id TEXT PRIMARY KEY,
        catch_id TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        buyer_id TEXT NOT NULL,
        price_per_kg REAL NOT NULL,
        price REAL NOT NULL,
        weight REAL NOT NULL,
        status TEXT NOT NULL,
        date_created TEXT NOT NULL,
        previous_counter_offer TEXT,
        catch_name TEXT NOT NULL,
        catch_image_url TEXT NOT NULL,
        fisher_name TEXT NOT NULL,
        fisher_rating REAL NOT NULL,
        fisher_avatar_url TEXT NOT NULL,
        buyer_name TEXT NOT NULL,
        buyer_rating REAL NOT NULL,
        buyer_avatar_url TEXT NOT NULL
      )
    ''');

    // --- ORDERS ---
    await db.execute('''
      CREATE TABLE orders (
        order_id TEXT PRIMARY KEY,
        offer_id TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        buyer_id TEXT NOT NULL,
        catch_snapshot TEXT NOT NULL,
        date_updated TEXT NOT NULL
      )
    ''');

    // --- CONVERSATIONS ---
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        buyer_id TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        contact_avatar_path TEXT NOT NULL,
        last_message TEXT NOT NULL,
        last_message_time TEXT NOT NULL,
        unread_count INTEGER NOT NULL
      )
    ''');
  }

  // --------------------------------------------------------------------------
  // FETCH CATCHES & OFFERS
  // --------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getOfferMapsByCatchId(
    String catchId,
  ) async {
    final db = await database;
    return await db.query(
      'offers',
      where: 'catch_id = ?',
      whereArgs: [catchId],
    );
  }

  /// Fetch all offers for a specific fisher (joined with catch and fisher info)
  Future<List<Map<String, dynamic>>> getOfferMapsByFisherId(
    String fisherId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT o.*, c.name AS catch_name, c.images AS catch_images, f.name AS fisher_name, f.rating AS fisher_rating
      FROM offers o
      INNER JOIN catches c ON o.catch_id = c.catch_id
      INNER JOIN users f ON o.fisher_id = f.id
      WHERE o.fisher_id = ?
      ''',
      [fisherId],
    );
  }

  // --------------------------------------------------------------------------
  // INSERT / UPDATE HELPERS
  // --------------------------------------------------------------------------

  Future<int> insertIfNotExists(
    String table,
    Map<String, dynamic> data,
    String idKey,
  ) async {
    final db = await database;
    try {
      final existing = await db.query(
        table,
        where: '$idKey = ?',
        whereArgs: [data[idKey]],
      );

      if (existing.isEmpty) {
        return await db.insert(table, data);
      } else {
        debugPrint('Record already exists in $table: ${data[idKey]}');
        return 0;
      }
    } catch (e) {
      debugPrint('Error inserting into $table: $e');
      return -1;
    }
  }

  Future<int> update(
    String table,
    String idKey,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    try {
      return await db.update(
        table,
        data,
        where: '$idKey = ?',
        whereArgs: [data[idKey]],
      );
    } catch (e) {
      debugPrint('Error updating $table with key $idKey: $e');
      return 0;
    }
  }

  // --------------------------------------------------------------------------
  // OTHER SELECTS
  // --------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getOrdersByUserId(String userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'buyer_id = ? OR fisher_id = ?',
      whereArgs: [userId, userId],
    );
  }

  Future<List<Map<String, dynamic>>> getConversationsByUserId(
    String userId,
  ) async {
    final db = await database;
    return await db.query(
      'conversations',
      where: 'buyer_id = ? OR fisher_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'last_message_time DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCatchMapsByFisherId(
    String fisherId,
  ) async {
    final db = await database;
    return await db.query(
      'catches',
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_created DESC',
    );
  }

  // --- Fetch available catches for the marketplace ---
  Future<List<Map<String, dynamic>>> getCatchMapsForMarket() async {
    final db = await database;
    return await db.query(
      'catches',
      where: 'status = ?',
      whereArgs: [CatchStatus.available.name],
      orderBy: 'date_created DESC',
    );
  }

  // --- Fetch offers by multiple catch IDs (bulk query) ---
  Future<List<Map<String, dynamic>>> getOfferMapsByCatchIds(
    List<String> catchIds,
  ) async {
    if (catchIds.isEmpty) return [];

    final db = await database;
    final placeholders = List.filled(catchIds.length, '?').join(',');
    return await db.rawQuery('''
    SELECT * FROM offers
    WHERE catch_id IN ($placeholders)
    ORDER BY date_created DESC
    ''', catchIds);
  }

  // --- Fetch orders for a buyer ---
  Future<List<Map<String, dynamic>>> getOrdersByBuyerId(String buyerId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'date_updated DESC',
    );
  }

  Future<Map<String, dynamic>?> getUserMapById(String userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // --------------------------------------------------------------------------
  // CLEAR TABLES
  // --------------------------------------------------------------------------

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('users');
    await db.delete('catches');
    await db.delete('offers');
    await db.delete('orders');
    await db.delete('conversations');
    debugPrint('All database tables cleared.');
  }
}
