import 'package:sqflite/sqflite.dart';

import '../../data/database/database_helper.dart';
import '../datasources/order_datasource.dart';
import '../persistence/order_entity.dart';

class OrderLocalDataSource implements OrderDataSource {
  final DatabaseHelper dbHelper;

  OrderLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => await dbHelper.database;

  @override
  Future<void> insertOrder(OrderEntity entity) async {
    final db = await _db;
    await db.insert(
      'orders',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteOrder(String id) async {
    final db = await _db;
    await db.delete('orders', where: 'order_id = ?', whereArgs: [id]);
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    final db = await _db;
    final rows = await db.query('orders', orderBy: 'date_updated DESC');
    return rows.map(OrderEntity.fromMap).toList();
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OrderEntity.fromMap(rows.first);
  }

  @override
  Future<List<OrderEntity>> getOrdersByUserId(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'orders',
      where: 'fisher_id = ? OR buyer_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'date_updated DESC',
    );
    return rows.map(OrderEntity.fromMap).toList();
  }

  @override
  Future<void> updateOrder(OrderEntity entity) async {
    final db = await _db;
    await db.update(
      'orders',
      entity.toMap(),
      where: 'order_id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<OrderEntity?> getOrderByOfferId(String offerId) async {
    final db = await _db;
    final rows = await db.query(
      'orders',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OrderEntity.fromMap(rows.first);
  }
}
