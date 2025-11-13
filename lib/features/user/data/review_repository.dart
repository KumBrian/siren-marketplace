import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';

/// The ReviewRepository handles all persistent storage operations related to
/// user ratings and reviews, utilizing the application's Sqflite DatabaseHelper.
class ReviewRepository {
  final DatabaseHelper _dbHelper;

  /// Constructor: Requires the DatabaseHelper instance.
  ReviewRepository(this._dbHelper);

  /// Fetches all review documents where the given [userId] is the user who was rated.
  ///
  /// This method is used by the ReviewsCubit to display the list of reviews
  /// and calculate the aggregate statistics.
  ///
  /// @param userId The ID of the user whose reviews are being retrieved (the rated user).
  /// @returns A Future that resolves to a list of raw Map data for the ReviewsCubit.
  Future<List<Map<String, dynamic>>> getReviewsForUser(String userId) async {
    try {
      // Delegate the fetch operation directly to the DatabaseHelper.
      final reviewMaps = await _dbHelper.getRatingsByUserId(userId);

      // The map keys must align with the Review.fromMap factory constructor
      // expected by the ReviewsCubit. Sqflite uses snake_case, which matches.
      return reviewMaps;
    } catch (e) {
      if (kDebugMode) {
        print('Sqflite Error (getReviewsForUser): $e');
      }
      rethrow;
    }
  }

  /// Handles the transactional logic for a user submitting a rating.
  /// This is called by the BuyerCubit (or OrdersBloc) and coordinates
  /// multiple database updates to ensure data integrity.
  ///
  /// This method performs the following steps:
  /// 1. Inserts the new rating record into the 'ratings' table.
  /// 2. Updates the specific order document with the new rating status (e.g., hasRatedFisher=1).
  /// 3. Recalculates and updates the rated user's aggregate rating and review count
  ///    in the 'users' table.
  Future<void> processRatingSubmission({
    required String orderId,
    required String raterId,
    required String ratedUserId,
    required double ratingValue,
    required bool isRatingBuyer,
    String? message,
  }) async {
    // --- 1. Insert the new rating record ---
    final ratingId = 'rating_${DateTime.now().microsecondsSinceEpoch}';
    final ratingData = {
      'rating_id': ratingId,
      'rater_id': raterId,
      'rated_user_id': ratedUserId,
      'order_id': orderId,
      'rating_value': ratingValue,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _dbHelper.insertRating(ratingData);

    // --- 2. Update the order status ---
    await _dbHelper.updateOrderRatingStatus(
      orderId: orderId,
      isRatingBuyer: isRatingBuyer,
      ratingValue: ratingValue,
      message: message,
    );

    // --- 3. Recalculate and update the user's aggregate rating ---

    // Fetch all existing ratings for the rated user
    final allRatings = await _dbHelper.getRatingsByUserId(ratedUserId);

    double totalRatingSum = 0;
    for (final ratingMap in allRatings) {
      // rating_value is stored as REAL in the database
      final value = (ratingMap['rating_value'] as num).toDouble();
      totalRatingSum += value;
    }

    final newReviewCount = allRatings.length;
    final newAverageRating = newReviewCount > 0
        ? totalRatingSum / newReviewCount
        : 0.0;

    await _dbHelper.updateUserRatingMetrics(
      userId: ratedUserId,
      newAverageRating: newAverageRating,
      newReviewCount: newReviewCount,
    );

    if (kDebugMode) {
      print(
        'Rating submission complete for order $orderId: '
        'User $ratedUserId now has average rating ${newAverageRating.toStringAsFixed(2)} '
        'across $newReviewCount reviews.',
      );
    }
  }
}
