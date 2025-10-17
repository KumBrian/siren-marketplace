import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:sqflite/sqflite.dart';

class OrderRepository {
  final DatabaseHelper dbHelper;
  final OfferRepository offerRepository;
  final FisherRepository fisherRepository;

  OrderRepository({
    required this.dbHelper,
    required this.offerRepository,
    required this.fisherRepository,
  });

  // --- CREATE ---

  Future<void> insertOrder(Order order) async {
    final db = await dbHelper.database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- READ ---

  Future<List<Map<String, dynamic>>> getAllOrderMaps() async {
    final db = await dbHelper.database;
    return await db.query('orders', orderBy: 'date_updated DESC');
  }

  Future<Order?> getOrderById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final m = maps.first;
    final offerId = m['offer_id'] as String?;
    final fisherId = m['fisher_id'] as String?;

    if (offerId == null || fisherId == null) return null;

    final offerMap = await offerRepository.getOfferMapById(offerId);
    final fisher = await fisherRepository.getFisherById(fisherId);

    if (offerMap == null) return null;

    final offer = Offer.fromMap(offerMap);
    return Order.fromMap(m: m, linkedOffer: offer, linkedFisher: fisher);
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    final db = await dbHelper.database;
    final rawOrders = await dbHelper.getOrdersByUserId(userId);

    final List<Order> orders = [];
    for (final m in rawOrders) {
      final offerMap = await offerRepository.getOfferMapById(m['offer_id']);
      final fisher = await fisherRepository.getFisherById(m['fisher_id']);
      if (offerMap == null) continue;

      final offer = Offer.fromMap(offerMap);
      orders.add(Order.fromMap(m: m, linkedOffer: offer, linkedFisher: fisher));
    }

    return orders;
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

  Future<Order?> getOrderByOfferId(String offerId) async {
    final m = await getOrderMapByOfferId(offerId);
    if (m == null) return null;

    final offerMap = await offerRepository.getOfferMapById(m['offer_id']);
    final fisher = await fisherRepository.getFisherById(m['fisher_id']);
    if (offerMap == null) return null;

    final offer = Offer.fromMap(offerMap);
    return Order.fromMap(m: m, linkedOffer: offer, linkedFisher: fisher);
  }

  Future<List<Map<String, dynamic>>> getOrderMapsByUserId(String userId) async {
    final db = await dbHelper.database;

    // This query gets all orders where the user is either the fisher or the buyer.
    return await db.query(
      'orders',
      where: 'fisher_id = ? OR buyer_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'date_updated DESC',
    );
  }

  // --- UPDATE ---

  Future<void> updateOrder(Order order) async {
    final db = await dbHelper.database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'order_id = ?',
      whereArgs: [order.id],
    );
  }

  // --- DELETE ---

  Future<void> deleteOrder(String id) async {
    final db = await dbHelper.database;
    await db.delete('orders', where: 'order_id = ?', whereArgs: [id]);
  }

  // --- UTILS ---

  Future<void> clearAllOrders() async {
    final db = await dbHelper.database;
    await db.delete('orders');
  }
}
