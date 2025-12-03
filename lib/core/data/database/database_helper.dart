import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

extension CatchStatusExtension on CatchStatus {
  String get name => toString().split('.').last;
}

class DatabaseHelper {
  static const _databaseName = "SirenMarketplaceDB.db";
  static const _databaseVersion = 13;

  // Table Names
  static const _usersTable = 'users';
  static const _catchesTable = 'catches';
  static const _offersTable = 'offers';
  static const _ordersTable = 'orders';
  static const _conversationsTable = 'conversations';
  static const _ratingsTable = 'ratings';

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
      onUpgrade: _onUpgrade,
    );
  }

  /// ------------------------------------------------------------------
  /// DATABASE MIGRATION LOGIC (Robust Drop & Recreate Strategy)
  /// ------------------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print(
        "Upgrading database from version $oldVersion to $newVersion. Dropping all tables and recreating schema.",
      );
    }

    // This is a robust but destructive migration. It ensures the new schema is
    // applied cleanly, which is acceptable since the seeder will repopulate data.
    final batch = db.batch();
    batch.execute('DROP TABLE IF EXISTS $_usersTable');
    batch.execute('DROP TABLE IF EXISTS $_catchesTable');
    batch.execute('DROP TABLE IF EXISTS $_offersTable');
    batch.execute('DROP TABLE IF EXISTS $_ordersTable');
    batch.execute('DROP TABLE IF EXISTS $_conversationsTable');
    batch.execute('DROP TABLE IF EXISTS $_ratingsTable');
    await batch.commit();

    // After dropping all tables, we call onCreate to rebuild the database
    // with the latest schema.
    await _onCreate(db, newVersion);
  }

  /// ------------------------------------------------------------------
  /// DATABASE CREATION LOGIC (Runs for new installs and after upgrades)
  /// ------------------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print("Creating database schema, version $version...");
    }
    final batch = db.batch();

    // 1. USERS
    batch.execute('''
      CREATE TABLE $_usersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_url TEXT,
        rating REAL,
        review_count INTEGER,
        role TEXT NOT NULL
      )
    ''');

    // 2. CATCHES
    batch.execute('''
      CREATE TABLE $_catchesTable (
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

    // 3. OFFERS
    batch.execute('''
      CREATE TABLE $_offersTable (
        offer_id TEXT PRIMARY KEY,
        catch_id TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        buyer_id TEXT NOT NULL,
        price_per_kg REAL NOT NULL,
        price REAL NOT NULL,
        weight REAL NOT NULL,
        status TEXT NOT NULL,
        has_update_for_buyer INTEGER NOT NULL DEFAULT 1,
        has_update_for_fisher INTEGER NOT NULL DEFAULT 1,
        date_created TEXT NOT NULL,
        date_updated TEXT NOT NULL,
        previous_price_per_kg REAL,
        previous_price REAL,
        previous_weight REAL,
        waiting_for TEXT
      )
    ''');

    // 4. ORDERS
    batch.execute('''
      CREATE TABLE $_ordersTable (
        order_id TEXT PRIMARY KEY,
        offer_id TEXT NOT NULL,
        catch_id TEXT NOT NULL,
        fisher_id TEXT NOT NULL,
        buyer_id TEXT NOT NULL,
        terms_price INTEGER NOT NULL,
        terms_weight INTEGER NOT NULL,
        terms_price_per_kg INTEGER NOT NULL,
        status TEXT NOT NULL,
        date_created TEXT NOT NULL,
        date_updated TEXT NOT NULL,
        has_review_from_fisher INTEGER NOT NULL DEFAULT 0,
        has_review_from_buyer INTEGER NOT NULL DEFAULT 0,
        cancellation_reason TEXT
      )
    ''');

    // 5. RATINGS
    batch.execute('''
      CREATE TABLE $_ratingsTable (
        rating_id TEXT PRIMARY KEY,
        rater_id TEXT NOT NULL,
        rated_user_id TEXT NOT NULL,
        order_id TEXT NOT NULL,
        rating_value REAL NOT NULL,
        message TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // 6. CONVERSATIONS
    batch.execute('''
      CREATE TABLE $_conversationsTable (
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

    await batch.commit();
    if (kDebugMode) {
      print("Database schema created successfully.");
    }
  }

  // --------------------------------------------------------------------------
  // FETCH CATCHES & OFFERS (Existing Selects)
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // OFFER METHODS
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getOfferMapById(String offerId) async {
    final db = await database;
    final maps = await db.query(
      _offersTable,
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllOfferMaps() async {
    final db = await database;
    return await db.query(_offersTable, orderBy: 'date_created DESC');
  }

  Future<List<Map<String, dynamic>>> getOfferMapsByCatchId(
    String catchId,
  ) async {
    final db = await database;
    return await db.query(
      _offersTable,
      where: 'catch_id = ?',
      whereArgs: [catchId],
    );
  }

  Future<List<Map<String, dynamic>>> getOfferMapsByBuyerId(
    String buyerId,
  ) async {
    final db = await database;
    // Join with catch info for display
    return await db.rawQuery(
      '''
      SELECT o.*, c.name AS catch_name, c.images AS catch_images
      FROM $_offersTable o
      INNER JOIN $_catchesTable c ON o.catch_id = c.catch_id
      WHERE o.buyer_id = ?
      ORDER BY o.date_created DESC
      ''',
      [buyerId],
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
      FROM $_offersTable o
      INNER JOIN $_catchesTable c ON o.catch_id = c.catch_id
      INNER JOIN $_usersTable f ON o.fisher_id = f.id
      WHERE o.fisher_id = ?
      ORDER BY o.date_created DESC
      ''',
      [fisherId],
    );
  }

  Future<List<Map<String, dynamic>>> getOfferMapsByStatus(String status) async {
    final db = await database;
    return await db.query(
      _offersTable,
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  // --------------------------------------------------------------------------
  // INSERT / UPDATE HELPERS (Existing CRUD)
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
  // RATING HELPER METHODS (NEW CRUD) 🌟
  // --------------------------------------------------------------------------

  /// **CREATE:** Inserts a new rating into the ratings table.
  Future<int> insertRating(Map<String, dynamic> ratingData) async {
    final db = await database;
    try {
      return await db.insert(
        _ratingsTable,
        ratingData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error inserting rating: $e');
      return -1;
    }
  }

  /// **UPDATE:** Updates the user's overall average rating and review count.
  Future<int> updateUserRatingMetrics({
    required String userId,
    required double newAverageRating,
    required int newReviewCount,
  }) async {
    final db = await database;
    try {
      return await db.update(
        _usersTable,
        {'rating': newAverageRating, 'review_count': newReviewCount},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint('Error updating user rating metrics for $userId: $e');
      return 0;
    }
  }

  /// **READ:** Fetches all ratings received by a specific user.
  Future<List<Map<String, dynamic>>> getRatingsByUserId(
    String ratedUserId,
  ) async {
    final db = await database;
    return await db.query(
      _ratingsTable,
      where: 'rated_user_id = ?',
      whereArgs: [ratedUserId],
      orderBy: 'timestamp DESC',
    );
  }

  /// **UPDATE:** Updates the rating flags and values on the orders table after a review submission.
  Future<int> updateOrderRatingStatus({
    required String orderId,
    required bool isRatingBuyer,
    required double ratingValue,
    String? message,
  }) async {
    final db = await database;

    // Only update the review flags - rating values are stored in ratings table
    final Map<String, dynamic> data = {};

    if (isRatingBuyer) {
      // If rating the buyer, the review is FROM the fisher
      data['has_review_from_fisher'] = 1;
    } else {
      // If rating the fisher, the review is FROM the buyer
      data['has_review_from_buyer'] = 1;
    }

    try {
      return await db.update(
        _ordersTable,
        data,
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    } catch (e) {
      debugPrint('Error updating order rating status for $orderId: $e');
      return 0;
    }
  }

  // --------------------------------------------------------------------------
  // OTHER SELECTS (Existing Selects)
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // ORDER METHODS
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getOrderMapById(String orderId) async {
    final db = await database;
    final maps = await db.query(
      _ordersTable,
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getOrderMapByOfferId(String offerId) async {
    final db = await database;
    final maps = await db.query(
      _ordersTable,
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllOrderMaps() async {
    final db = await database;
    return await db.query(_ordersTable, orderBy: 'date_updated DESC');
  }

  Future<List<Map<String, dynamic>>> getOrdersByUserId(String userId) async {
    final db = await database;
    return await db.query(
      _ordersTable,
      where: 'buyer_id = ? OR fisher_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'date_updated DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getOrdersByFisherId(
    String fisherId,
  ) async {
    final db = await database;
    return await db.query(
      _ordersTable,
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_updated DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final db = await database;
    return await db.query(
      _ordersTable,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date_updated DESC',
    );
  }

  Future<Map<String, dynamic>?> getCatchMapById(String catchId) async {
    final db = await database;
    final maps = await db.query(
      _catchesTable,
      where: 'catch_id = ?',
      whereArgs: [catchId],
      limit: 1,
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getConversationsByUserId(
    String userId,
  ) async {
    final db = await database;
    return await db.query(
      _conversationsTable,
      where: 'buyer_id = ? OR fisher_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'last_message_time DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCatchMapsForMarket() async {
    final db = await database;
    return await db.query(
      _catchesTable,
      where: 'status = ? OR status = ?',
      // Only show 'available'
      whereArgs: [CatchStatus.available.name, CatchStatus.soldOut.name],
      // Filter out 'removed' and 'expired'
      orderBy: 'date_created DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCatchMapsByFisherId(
    String fisherId,
  ) async {
    final db = await database;
    // Fisher needs to see ALL their catches, including removed/expired/sold out.
    return await db.query(
      _catchesTable,
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
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
    SELECT * FROM $_offersTable
    WHERE catch_id IN ($placeholders)
    ORDER BY date_created DESC
    ''', catchIds);
  }

  // --- Fetch orders for a buyer ---
  Future<List<Map<String, dynamic>>> getOrdersByBuyerId(String buyerId) async {
    final db = await database;
    return await db.query(
      _ordersTable,
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'date_updated DESC',
    );
  }

  Future<Map<String, dynamic>?> getUserMapById(String userId) async {
    final db = await database;
    final maps = await db.query(
      _usersTable,
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

  // --------------------------------------------------------------------------
  // REVIEW METHODS
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getReviewMapById(String reviewId) async {
    final db = await database;
    final maps = await db.query(
      _ratingsTable,
      where: 'rating_id = ?',
      whereArgs: [reviewId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getReviewsByReviewerId(
    String reviewerId,
  ) async {
    final db = await database;
    return await db.query(
      _ratingsTable,
      where: 'rater_id = ?',
      whereArgs: [reviewerId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReviewsForOrder(String orderId) async {
    final db = await database;
    return await db.query(
      _ratingsTable,
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  }) async {
    final db = await database;
    final maps = await db.query(
      _ratingsTable,
      where: 'order_id = ? AND rater_id = ? AND rated_user_id = ?',
      whereArgs: [orderId, reviewerId, reviewedUserId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteReview(String reviewId) async {
    final db = await database;
    return await db.delete(
      _ratingsTable,
      where: 'rating_id = ?',
      whereArgs: [reviewId],
    );
  }

  // --------------------------------------------------------------------------
  // TRANSACTION SUPPORT
  // --------------------------------------------------------------------------

  Future<T> transaction<T>(Future<T> Function() action) async {
    final db = await database;
    return await db.transaction((txn) async => await action());
  }

  // --------------------------------------------------------------------------
  // CLEAR TABLES
  // --------------------------------------------------------------------------

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(_usersTable);
    await db.delete(_catchesTable);
    await db.delete(_offersTable);
    await db.delete(_ordersTable);
    await db.delete(_conversationsTable);
    await db.delete(_ratingsTable);
    debugPrint('All database tables cleared.');
  }
}
