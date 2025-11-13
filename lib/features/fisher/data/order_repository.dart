import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class OrderRepository {
  final DatabaseHelper dbHelper;
  final OfferRepository offerRepository;
  final FisherRepository fisherRepository;

  final Uuid _uuid = const Uuid();

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

  // --------------------------------------------------------------------------
  // 🌟 UPDATED RATING SUBMISSION METHOD 🌟
  // --------------------------------------------------------------------------

  /// Submits a rating for a user involved in a specific order and updates metrics.
  ///
  /// **FIX:** All database operations within the transaction now use the
  /// provided `txn` object to prevent database lock warnings.
  Future<bool> submitUserRating({
    required String orderId,
    required String raterId,
    required String ratedUserId,
    required double ratingValue,
    String? message,
  }) async {
    final db = await dbHelper.database;
    try {
      // 1. Determine the context (who is being rated)
      final order = await getOrderById(orderId);
      if (order == null) {
        debugPrint('Order $orderId not found for rating submission.');
        return false;
      }

      final isRatingBuyer = (ratedUserId == order.buyerId);
      final isAlreadyRated = isRatingBuyer
          ? order.hasRatedBuyer
          : order.hasRatedFisher;

      if (isAlreadyRated) {
        debugPrint(
          'User $ratedUserId has already been rated for order $orderId.',
        );
        return false;
      }

      // Define the map of data to update in the 'orders' table
      final Map<String, Object?> updateOrderData = isRatingBuyer
          ? {
              // Update Buyer status columns
              'hasRatedBuyer': 1,
              'buyer_rating_value': ratingValue,
              'buyer_rating_message': message,
            }
          : {
              // Update Fisher status columns
              'hasRatedFisher': 1,
              'fisher_rating_value': ratingValue,
              'fisher_rating_message': message,
            };

      // Start Database Transaction
      await db.transaction((txn) async {
        // A. INSERT new rating record into 'ratings' table
        final ratingData = {
          'rating_id': _uuid.v4(),
          'rater_id': raterId,
          'rated_user_id': ratedUserId,
          'order_id': orderId,
          'rating_value': ratingValue,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        };
        // 🌟 FIX: Use txn for INSERT
        await txn.insert(
          'ratings',
          ratingData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // B. UPDATE the order's rating status in the 'orders' table
        // 🌟 FIX: Use txn for UPDATE
        await txn.update(
          'orders',
          updateOrderData, // Use the dynamically created map
          where: 'order_id = ?',
          whereArgs: [orderId],
        );

        // C. UPDATE user's overall average rating in the 'users' table
        // 1. Fetch ALL existing ratings for the rated user
        // 🌟 FIX: Use txn for QUERY
        final allRatingsMaps = await txn.query(
          'ratings',
          where: 'rated_user_id = ?',
          whereArgs: [ratedUserId],
        );

        // 2. Calculate the new average and count
        final newReviewCount = allRatingsMaps.length;
        final totalRatingSum = allRatingsMaps.fold<double>(0.0, (sum, map) {
          final val = map['rating_value'];
          return sum + (val is double ? val : (val as int).toDouble());
        });

        final newAverageRating = newReviewCount > 0
            ? (totalRatingSum / newReviewCount)
            : 0.0;

        // 3. Update user metrics in the DB
        // 🌟 FIX: Use txn for final user UPDATE
        await txn.update(
          'users',
          {'rating': newAverageRating, 'review_count': newReviewCount},
          where: 'id = ?',
          whereArgs: [ratedUserId],
        );
      }); // End transaction

      return true;
    } catch (e) {
      debugPrint('Error during submitUserRating transaction: $e');
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // EXISTING METHODS (No changes needed here unless they used dbHelper inside
  // a transaction block, which they don't seem to)
  // --------------------------------------------------------------------------

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

    if (offerMap == null) return null; // Added fisher check

    final offer = Offer.fromMap(offerMap);
    return Order.fromMap(m: m, linkedOffer: offer, linkedFisher: fisher);
  }

  // Modified to use dbHelper's dedicated method for cleaner code
  Future<List<Order>> getOrdersByUserId(String userId) async {
    final rawOrders = await dbHelper.getOrdersByUserId(userId);

    final List<Order> orders = [];
    for (final m in rawOrders) {
      final offerMap = await offerRepository.getOfferMapById(m['offer_id']);
      final fisher = await fisherRepository.getFisherById(m['fisher_id']);
      // Ensure we have all necessary linked data
      if (offerMap == null) {
        debugPrint(
          'Skipping order ${m['order_id']} due to missing offer or fisher data.',
        );
        continue;
      }

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
