import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database/database_helper.dart';
import '../../../../core/domain/enums/order_status.dart';
import '../../models/order_model.dart';
import '../interfaces/i_order_datasource.dart';

class LocalOrderDataSource implements IOrderDataSource {
  final DatabaseHelper dbHelper;

  LocalOrderDataSource({required this.dbHelper});

  @override
  Future<String> create(OrderModel order) async {
    final db = await dbHelper.database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return order.id;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final maps = await dbHelper.getAllOrderMaps();
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  @override
  Future<OrderModel?> getById(String orderId) async {
    final map = await dbHelper.getOrderMapById(orderId);
    return map != null ? OrderModel.fromMap(map) : null;
  }

  @override
  Future<OrderModel?> getByOfferId(String offerId) async {
    final map = await dbHelper.getOrderMapByOfferId(offerId);
    return map != null ? OrderModel.fromMap(map) : null;
  }

  @override
  Future<List<OrderModel>> getByUserId(String userId) async {
    final maps = await dbHelper.getOrdersByUserId(userId);
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  @override
  Future<List<OrderModel>> getByFisherId(String fisherId) async {
    final maps = await dbHelper.getOrdersByFisherId(fisherId);
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  @override
  Future<List<OrderModel>> getByBuyerId(String buyerId) async {
    final maps = await dbHelper.getOrdersByBuyerId(buyerId);
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  @override
  Future<List<OrderModel>> getByStatus(OrderStatus status) async {
    final maps = await dbHelper.getOrdersByStatus(status.name);
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  @override
  Future<void> update(OrderModel order) async {
    final db = await dbHelper.database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'order_id = ?',
      whereArgs: [order.id],
    );
  }

  @override
  Future<void> delete(String orderId) async {
    final db = await dbHelper.database;
    await db.delete('orders', where: 'order_id = ?', whereArgs: [orderId]);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dbHelper.transaction(action);
  }

  @override
  Future<OrderModel?> relistOrder(
    String orderId,
    String cancellationReason,
  ) async {
    // Local implementation pending - just return null or generic update
    return null;
  }
}
