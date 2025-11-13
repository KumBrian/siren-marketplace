import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/features/user/data/models/review_model.dart';
import 'package:siren_marketplace/features/user/data/review_repository.dart'; // Retaining original import for ReviewRepository

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  // Repositories must be injected during setup
  final ReviewRepository _reviewRepository;
  final UserRepository _userRepository;

  ReviewsCubit(this._reviewRepository, this._userRepository)
    : super(ReviewsInitial());

  /// Loads all reviews for a specific user ID (the user being rated).
  Future<void> loadReviews({required String userId}) async {
    if (state is ReviewsLoading) return;

    emit(ReviewsLoading());
    try {
      // 1. Fetch raw review maps from the repository
      final rawReviewMaps = await _reviewRepository.getReviewsForUser(userId);

      // 2. Aggregate metrics and fetch rater details
      double totalRating = 0;
      final Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final List<Review> assembledReviews = [];

      for (final reviewMap in rawReviewMaps) {
        final raterId = reviewMap['rater_id'] as String;
        // Fetch the profile of the user who submitted the rating
        final raterMap = await _userRepository.getUserMapById(raterId);

        if (raterMap != null) {
          // FIX: Safely retrieve name and avatar_url. Use `as String?` to allow null,
          // then provide a fallback to ensure a non-null String is passed to Review.
          final raterName = (raterMap['name'] as String?) ?? 'Unknown User';
          final raterAvatarUrl = (raterMap['avatar_url'] as String?) ?? '';

          final review = Review.fromMap(
            reviewMap,
            raterName: raterName,
            raterAvatarUrl: raterAvatarUrl,
          );

          assembledReviews.add(review);
          totalRating += review.ratingValue;

          final ratingKey = review.ratingValue.toInt();
          // Ensure we only process ratings 1 through 5
          if (ratingKey >= 1 && ratingKey <= 5) {
            distribution[ratingKey] = (distribution[ratingKey] ?? 0) + 1;
          }
        }
      }

      final totalReviews = assembledReviews.length;
      final averageRating = totalReviews > 0 ? totalRating / totalReviews : 0.0;

      emit(
        ReviewsLoaded(
          averageRating: averageRating,
          totalReviews: totalReviews,
          ratingDistribution: distribution,
          // Sort reviews by date string descending (newest first)
          // This relies on the date string being lexicographically sortable (e.g., '2023-11-20...')
          reviews: assembledReviews
            ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated)),
        ),
      );
    } catch (e) {
      emit(ReviewsError('Failed to load reviews: ${e.toString()}'));
    }
  }
}
