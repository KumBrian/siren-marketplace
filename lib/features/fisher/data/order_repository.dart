import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:sqflite/sqflite.dart';

class OrderRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // --- ORDER METHODS ---

  Future<void> insertOrder(Order order) async {
    final db = await dbHelper.database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrderMaps() async {
    final db = await dbHelper.database;
    return await db.query('orders', orderBy: 'date_updated DESC');
  }

  Future<Map<String, dynamic>?> getOrderMapById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // 🆕 NEW: Fetch all raw Order maps where the user is either the Fisher or the Buyer.
  /// This single method replaces both getFisherOrderMaps and getBuyerOrderMaps.
  Future<List<Map<String, dynamic>>> getOrderMapsByUserId(String userId) async {
    // Uses the dedicated DatabaseHelper method for dual-role querying
    return await dbHelper.getOrdersByUserId(userId);
  }

  Future<Map<String, dynamic>?> getOrderMapByOfferId(String offerId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<Map<String, dynamic>?> getOrderByOfferId(String offerId) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'orders',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> deleteOrder(String id) async {
    final db = await dbHelper.database;
    await db.delete('orders', where: 'order_id = ?', whereArgs: [id]);
  }
}
