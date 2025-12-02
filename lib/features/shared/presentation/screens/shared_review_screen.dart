import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/providers/review_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/rating_card.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/review_card.dart';

class SharedReviewScreen extends ConsumerWidget {
  final String userId;

  const SharedReviewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    final reviewsAsync = ref.watch(reviewsForUserProvider(userId));
    final statsAsync = ref.watch(userReviewStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          data: (user) => Text(
            'Reviews for ${user?.name ?? "User"}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          loading: () => const Text(
            'User Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          error: (_, __) => const Text(
            'User Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: userAsync.maybeWhen(
                data: (user) =>
                    Text('No reviews yet for ${user?.name ?? "this user"}.'),
                orElse: () => const Text('No reviews yet for this user.'),
              ),
            );
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

                      // Fetch reviewer info
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
