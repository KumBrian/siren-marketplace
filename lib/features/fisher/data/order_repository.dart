import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Repository responsible for executing all data operations related to
/// marketplace orders.
///
/// This repository currently interacts with a local SQLite database through
/// [DatabaseHelper]. In future iterations, this class can be migrated to a
/// remote API–driven architecture without changing upstream business logic.
/// Local DB reads/writes can be swapped with REST/GraphQL calls while the
/// repository methods remain stable.
///
/// Responsibilities:
/// - Create, read, update, and delete orders.
/// - Resolve linked domain objects such as offers and fishers.
/// - Handle user ratings and update aggregate metrics.
/// - Provide transactional safety for multi–step writes.
class OrderRepository {
  /// Reference to the local database.
  final DatabaseHelper dbHelper;

  /// Reference to the offer repository.
  final OfferRepository offerRepository;

  /// Reference to the fisher repository.
  final FisherRepository fisherRepository;

  final Uuid _uuid = const Uuid();

  /// Create a new [OrderRepository] instance.
  OrderRepository({
    required this.dbHelper,
    required this.offerRepository,
    required this.fisherRepository,
  });

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  /// Inserts a new [Order] into the database.
  ///
  /// If an entry with the same ID exists, it is replaced due to
  /// [ConflictAlgorithm.replace].
  ///
  /// This method is a candidate for API adoption:
  /// replacing this write operation with a remote `POST /orders` endpoint
  /// preserves compatibility with the rest of the feature layer.
  Future<void> insertOrder(Order order) async {
    final db = await dbHelper.database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // RATING SUBMISSION WORKFLOW
  // ---------------------------------------------------------------------------

  /// Submits a rating for one user related to a specific order.
  ///
  /// This includes:
  /// - Validating order existence.
  /// - Determining whether the rater is reviewing the buyer or the fisher.
  /// - Preventing duplicate ratings.
  /// - Writing the rating entry into the `ratings` table.
  /// - Updating rating metadata inside the `orders` table.
  /// - Recomputing the rated user's average rating and total review count.
  ///
  /// All operations occur inside a database transaction to avoid incomplete
  /// writes or UI inconsistencies.
  ///
  /// Returns `true` if the operation succeeds, otherwise `false`.
  ///
  /// In API–based architecture, this would become:
  /// - `POST /ratings`
  /// - followed by remote recomputation of user metrics.
  Future<bool> submitUserRating({
    required String orderId,
    required String raterId,
    required String ratedUserId,
    required double ratingValue,
    String? message,
  }) async {
    final db = await dbHelper.database;

    try {
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

      final Map<String, Object?> updateOrderData = isRatingBuyer
          ? {
              'hasRatedBuyer': 1,
              'buyer_rating_value': ratingValue,
              'buyer_rating_message': message,
            }
          : {
              'hasRatedFisher': 1,
              'fisher_rating_value': ratingValue,
              'fisher_rating_message': message,
            };

      await db.transaction((txn) async {
        // Insert rating record
        await txn.insert('ratings', {
          'rating_id': _uuid.v4(),
          'rater_id': raterId,
          'rated_user_id': ratedUserId,
          'order_id': orderId,
          'rating_value': ratingValue,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Update order metadata
        await txn.update(
          'orders',
          updateOrderData,
          where: 'order_id = ?',
          whereArgs: [orderId],
        );

        // Fetch all ratings for recomputing metrics
        final allRatingsMaps = await txn.query(
          'ratings',
          where: 'rated_user_id = ?',
          whereArgs: [ratedUserId],
        );

        final newReviewCount = allRatingsMaps.length;
        final ratingSum = allRatingsMaps.fold<double>(0.0, (sum, map) {
          final v = map['rating_value'];
          return sum + (v is double ? v : (v as int).toDouble());
        });

        final newAverage = newReviewCount > 0
            ? ratingSum / newReviewCount
            : 0.0;

        // Update user metrics
        await txn.update(
          'users',
          {'rating': newAverage, 'review_count': newReviewCount},
          where: 'id = ?',
          whereArgs: [ratedUserId],
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error during submitUserRating transaction: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Returns all order rows as raw map objects.
  ///
  /// This is primarily used by admin views or background sync jobs.
  Future<List<Map<String, dynamic>>> getAllOrderMaps() async {
    final db = await dbHelper.database;
    return db.query('orders', orderBy: 'date_updated DESC');
  }

  /// Retrieves a complete [Order] by its ID.
  ///
  /// Includes:
  /// - Linked [Offer]
  /// - Linked [Fisher]
  ///
  /// Returns null if:
  /// - No order exists.
  /// - Referenced offer or fisher entries cannot be found.
  ///
  /// When migrated to API architecture:
  /// this becomes a simple `GET /orders/{id}` that returns composite data.
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

  /// Retrieves all [Order] objects where the specified user is either the
  /// fisher or buyer.
  ///
  /// This is typically used by dashboards or activity screens.
  Future<List<Order>> getOrdersByUserId(String userId) async {
    final rawOrders = await dbHelper.getOrdersByUserId(userId);
    final List<Order> orders = [];

    for (final m in rawOrders) {
      final offerMap = await offerRepository.getOfferMapById(m['offer_id']);
      final fisher = await fisherRepository.getFisherById(m['fisher_id']);

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

  /// Retrieves a raw order map based on its associated offer ID.
  ///
  /// Returns `null` if no order is linked to the given offer.
  Future<Map<String, dynamic>?> getOrderMapByOfferId(String offerId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// Retrieves a full [Order] based on its associated offer ID.
  ///
  /// Useful for flows where each offer is expected to have at most
  /// one active order.
  Future<Order?> getOrderByOfferId(String offerId) async {
    final m = await getOrderMapByOfferId(offerId);
    if (m == null) return null;

    final offerMap = await offerRepository.getOfferMapById(m['offer_id']);
    final fisher = await fisherRepository.getFisherById(m['fisher_id']);
    if (offerMap == null) return null;

    final offer = Offer.fromMap(offerMap);
    return Order.fromMap(m: m, linkedOffer: offer, linkedFisher: fisher);
  }

  /// Retrieves raw order maps where the user is either the fisher or buyer.
  ///
  /// This lower–level version is useful for batch processing and sync logic.
  Future<List<Map<String, dynamic>>> getOrderMapsByUserId(String userId) async {
    final db = await dbHelper.database;
    return db.query(
      'orders',
      where: 'fisher_id = ? OR buyer_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'date_updated DESC',
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  /// Updates an existing order record.
  ///
  /// All fields are replaced using data from [Order.toMap].
  Future<void> updateOrder(Order order) async {
    final db = await dbHelper.database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'order_id = ?',
      whereArgs: [order.id],
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  /// Deletes an order by its ID.
  ///
  /// This does not delete linked offers, fishers, or ratings.
  Future<void> deleteOrder(String id) async {
    final db = await dbHelper.database;
    await db.delete('orders', where: 'order_id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // UTILITIES
  // ---------------------------------------------------------------------------

  /// Clears all order records from the database.
  ///
  /// Warning: This is destructive and intended for development, testing,
  /// or emergency reset flows.
  Future<void> clearAllOrders() async {
    final db = await dbHelper.database;
    await db.delete('orders');
  }
}
