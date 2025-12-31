import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/providers/review_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/rating_card.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/review_card.dart';

/// Screen to display reviews for a specific user.
///
/// Can optionally accept [userName] to avoid fetching user details if already known.
class SharedReviewScreen extends ConsumerWidget {
  /// The ID of the user whose reviews are being displayed.
  final String userId;

  /// Optional name of the user. If provided, skips fetching user details from [userProvider].
  final String? userName;

  const SharedReviewScreen({super.key, required this.userId, this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only fetch user if name is not provided
    final shouldFetchUser = userName == null;
    final userAsync = shouldFetchUser
        ? ref.watch(userProvider(userId))
        : const AsyncValue<User?>.loading();

    final reviewsAsync = ref.watch(reviewsForUserProvider(userId));
    final statsAsync = ref.watch(userReviewStatsProvider(userId));

    final displayName = userName ?? userAsync.value?.name ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews for $displayName',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(child: Text('No reviews yet for $displayName.'));
          }

          // Sort reviews by date descending
          final sortedReviews = List<Review>.from(reviews)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating summary card
                statsAsync.when(
                  data: (stats) => RatingCard(
                    averageRating: stats.averageRating,
                    totalReviews: stats.totalReviews,
                    ratingDistribution: stats.ratingDistribution,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                // Reviews list
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedReviews.length,
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 4,
                      child: Divider(color: AppColors.gray200),
                    ),
                    itemBuilder: (context, index) {
                      final review = sortedReviews[index];

                      // Use reviewerName if available from API, otherwise fetch
                      if (review.reviewerName != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ReviewCard(
                            rating: review.rating.value.toInt(),
                            name: review.reviewerName!,
                            date: review.timestamp.toFormattedDate(),
                            image:
                                '', // Avatar URL not available in this simplified flow yet
                            message: review.comment ?? 'No comment provided.',
                          ),
                        );
                      }

                      // Fallback to fetching reviewer info
                      return Consumer(
                        builder: (context, ref, _) {
                          final reviewerAsync = ref.watch(
                            userProvider(review.reviewerId),
                          );

                          return reviewerAsync.when(
                            data: (reviewer) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ReviewCard(
                                rating: review.rating.value.toInt(),
                                name: reviewer?.name ?? 'Unknown',
                                date: review.timestamp.toFormattedDate(),
                                image: reviewer?.avatarUrl ?? '',
                                message:
                                    review.comment ?? 'No comment provided.',
                              ),
                            ),
                            loading: () => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ReviewCard(
                                rating: review.rating.value.toInt(),
                                name: 'Loading...',
                                date: review.timestamp.toFormattedDate(),
                                image: '',
                                message:
                                    review.comment ?? 'No comment provided.',
                              ),
                            ),
                            error: (_, __) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ReviewCard(
                                rating: review.rating.value.toInt(),
                                name: 'Unknown',
                                date: review.timestamp.toFormattedDate(),
                                image: '',
                                message:
                                    review.comment ?? 'No comment provided.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load reviews: $error')),
      ),
    );
  }
}
