import 'dart:math';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'package:uuid/uuid.dart';

class ReviewSeeder {
  final Uuid _uuid = const Uuid();
  final Random _rng = Random();

  Future<void> seed(List<Order> seededOrders) async {
    final userRepository = sl<IUserRepository>();
    final databaseHelper = sl<DatabaseHelper>();

    final List<String> reviewMessages = [
      "Excellent quality and fast service. Highly recommended!",
      "The catch was exactly as described. Very reliable fisher.",
      "Fair price and great communication. Will buy again.",
      "Smooth transaction. Professional buyer, prompt payment.",
      "The product was fresh, but delivery was a little slow.",
      "A pleasure to deal with this user.",
      "Satisfied with the purchase, no issues.",
    ];

    // Track ratings per user to update aggregates at the end
    final Map<String, List<double>> userRatings = {};
    int reviewCount = 0;

    for (int i = 0; i < seededOrders.length; i++) {
      if (i % 3 != 0) continue;

      final order = seededOrders[i];

      final fisherToBuyerRating = (_rng.nextInt(2) + 4)
          .toDouble(); // 4.0 or 5.0
      final buyerReviewMessage =
          reviewMessages[_rng.nextInt(reviewMessages.length)];

      await databaseHelper.insertRating({
        'rating_id': _uuid.v4(),
        'order_id': order.id,
        'rater_id': order.fisherId,
        'rated_user_id': order.buyerId,
        'rating_value': fisherToBuyerRating,
        'message': buyerReviewMessage,
        'timestamp': DateTime.now()
            .subtract(Duration(hours: 10 + i * 2))
            .toIso8601String(),
      });

      await databaseHelper.updateOrderRatingStatus(
        orderId: order.id,
        isRatingBuyer: true,
        ratingValue: fisherToBuyerRating,
        message: buyerReviewMessage,
      );

      // Track buyer rating
      userRatings.putIfAbsent(order.buyerId, () => []).add(fisherToBuyerRating);

      reviewCount++;

      if (i % 6 == 0) {
        final buyerToFisherRating = (_rng.nextInt(2) + 4).toDouble();
        final fisherReviewMessage =
            reviewMessages[_rng.nextInt(reviewMessages.length)];

        await databaseHelper.insertRating({
          'rating_id': _uuid.v4(),
          'order_id': order.id,
          'rater_id': order.buyerId,
          'rated_user_id': order.fisherId,
          'rating_value': buyerToFisherRating,
          'message': fisherReviewMessage,
          'timestamp': DateTime.now()
              .subtract(Duration(hours: 5 + i * 2))
              .toIso8601String(),
        });

        await databaseHelper.updateOrderRatingStatus(
          orderId: order.id,
          isRatingBuyer: false, // Target is the Fisher
          ratingValue: buyerToFisherRating,
          message: fisherReviewMessage,
        );

        // Track fisher rating
        userRatings
            .putIfAbsent(order.fisherId, () => [])
            .add(buyerToFisherRating);

        reviewCount++;
      }
    }

    // Update all users with their calculated ratings
    for (final entry in userRatings.entries) {
      final userId = entry.key;
      final ratings = entry.value;
      final count = ratings.length;
      final average = ratings.reduce((a, b) => a + b) / count;

      await userRepository.updateRating(
        userId: userId,
        rating: Rating.fromValue(average),
        reviewCount: count,
      );
    }

    print(
      '$reviewCount total reviews seeded. User profiles and Orders updated.',
    );
  }
}
