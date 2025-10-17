import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

class BuyerRepository {
  final DatabaseHelper dbHelper;

  BuyerRepository({required this.dbHelper});

  // --- FETCH ORDERS FOR A BUYER ---
  Future<List<Order>> getOrdersByBuyerId(String buyerId) async {
    final orderMaps = await dbHelper.getOrdersByBuyerId(buyerId);

    final List<Order> orders = [];

    for (final oMap in orderMaps) {
      // 1️⃣ Fetch linked offer
      final offerId = oMap['offer_id'] as String;
      final offerMaps = await dbHelper.getOfferMapsByCatchId(offerId);
      if (offerMaps.isEmpty) continue;
      final offer = Offer.fromMap(offerMaps.first);

      // 2️⃣ Fetch linked fisher
      final fisherId = oMap['fisher_id'] as String;
      final userMap = await dbHelper.getUserMapById(fisherId);
      if (userMap == null) continue;
      final fisher = Fisher.fromMap(userMap);

      // 3️⃣ Assemble Order from map + linked objects
      final order = Order.fromMap(
        m: oMap,
        linkedOffer: offer,
        linkedFisher: fisher,
      );

      orders.add(order);
    }

    return orders;
  }

  // --- FETCH MARKET CATCHES ---
  Future<List<Catch>> getMarketCatches() async {
    final catchMaps = await dbHelper.getCatchMapsForMarket();

    if (catchMaps.isEmpty) return [];

    final catches = catchMaps.map((m) => Catch.fromMap(m)).toList();

    // Fetch all offers for these catches
    final catchIds = catches.map((c) => c.id).toList();
    final offerMaps = await dbHelper.getOfferMapsByCatchIds(catchIds);

    final Map<String, List<Offer>> offersByCatch = {};
    for (final map in offerMaps) {
      final offer = Offer.fromMap(map);
      offersByCatch.putIfAbsent(offer.catchId, () => []).add(offer);
    }

    // Attach offers to their respective Catch objects
    return catches
        .map((c) => c.copyWith(offers: offersByCatch[c.id] ?? []))
        .toList();
  }

  // --- FETCH SINGLE ORDER BY ID ---
  Future<Order?> getOrderById(String orderId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final oMap = maps.first;

    final offerId = oMap['offer_id'] as String;
    final offerMaps = await dbHelper.getOfferMapsByCatchId(offerId);
    if (offerMaps.isEmpty) return null;
    final offer = Offer.fromMap(offerMaps.first);

    final fisherId = oMap['fisher_id'] as String;
    final userMap = await dbHelper.getUserMapById(fisherId);
    if (userMap == null) return null;
    final fisher = Fisher.fromMap(userMap);

    return Order.fromMap(m: oMap, linkedOffer: offer, linkedFisher: fisher);
  }
}
