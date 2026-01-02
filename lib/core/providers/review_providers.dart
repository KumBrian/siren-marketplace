import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/domain/repositories/i_review_repository.dart';

import 'package:siren_marketplace/core/providers/user_providers.dart';

/// Provider to fetch a Review by ID
final reviewProvider = FutureProvider.family<Review?, String>((ref, id) async {
  final repository = sl<IReviewRepository>();
  return repository.getById(id);
});

/// Provider to fetch reviews for a specific user.
///
/// "Smart" provider that switches to [getMyReviews] if the [userId] matches
/// the currently logged-in user.
final reviewsForUserProvider = FutureProvider.family<List<Review>, String>((
  ref,
  userId,
) async {
  final repository = sl<IReviewRepository>();
  final currentUser = ref.read(currentUserProvider).value;

  print(
    'reviewsForUserProvider: Fetching reviews for userId: $userId. Current user: ${currentUser?.id}',
  );

  // Check if we are fetching for the current user
  if (currentUser != null && currentUser.id == userId) {
    print('reviewsForUserProvider: Match found! Fetching MY reviews.');
    return repository.getMyReviews();
  }

  print('reviewsForUserProvider: Fetching reviews for OTHER user.');
  return repository.getReviewsForUser(userId);
});

class UserReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const UserReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}

final userReviewStatsProvider =
    Provider.family<AsyncValue<UserReviewStats>, String>((ref, userId) {
      final reviewsAsync = ref.watch(reviewsForUserProvider(userId));

      return reviewsAsync.whenData((reviews) {
        if (reviews.isEmpty) {
          return const UserReviewStats(
            averageRating: 0,
            totalReviews: 0,
            ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          );
        }

        double totalRating = 0;
        final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

        for (final review in reviews) {
          final ratingValue = review.rating.value.round();
          // Ensure rating is within 1-5 range for distribution map
          final clampedRating = ratingValue.clamp(1, 5);

          totalRating += review.rating.value;
          distribution[clampedRating] = (distribution[clampedRating] ?? 0) + 1;
        }

        return UserReviewStats(
          averageRating: totalRating / reviews.length,
          totalReviews: reviews.length,
          ratingDistribution: distribution,
        );
      });
    });
