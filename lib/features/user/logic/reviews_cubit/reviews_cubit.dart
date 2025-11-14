import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/features/user/data/models/review_model.dart';

part 'reviews_state.dart';

/// Manages the end-to-end lifecycle of user review retrieval and aggregation.
/// This cubit provides a consolidated, production-ready pipeline for loading
/// reviews, enriching them with rater metadata, and emitting rated output
/// metrics (average score, distribution, and sorted lists).
class ReviewsCubit extends Cubit<ReviewsState> {
  final DatabaseHelper _databaseHelper;
  final UserRepository _userRepository;

  ReviewsCubit(this._databaseHelper, this._userRepository)
    : super(ReviewsInitial());

  /// Loads all reviews associated with a target user ID.
  ///
  /// Operational flow:
  /// 1. Fetch raw review entries from the database layer.
  /// 2. Resolve each rater’s profile data (name, avatar).
  /// 3. Assemble domain-level `Review` objects.
  /// 4. Compute aggregate analytics (average score + distribution).
  /// 5. Order the final dataset by creation date descending.
  ///
  /// All heavy-lifting is wrapped in structured state transitions to guarantee
  /// predictable UI behavior across loading, success, and error boundaries.
  Future<void> loadReviews({required String userId}) async {
    // Prevent concurrent load operations for stability.
    if (state is ReviewsLoading) return;

    emit(ReviewsLoading());

    try {
      // Retrieve all raw review rows for the target user.
      final rawReviewMaps = await _databaseHelper.getRatingsByUserId(userId);

      double totalRating = 0;
      final Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final List<Review> assembledReviews = [];

      // Iterate through each review entry and hydrate it with rater metadata.
      for (final reviewMap in rawReviewMaps) {
        final raterId = reviewMap['rater_id'] as String;

        // Lookup rater profile data.
        final raterMap = await _userRepository.getUserMapById(raterId);

        if (raterMap != null) {
          // Safe extraction with fallback to maintain data integrity.
          final raterName = (raterMap['name'] as String?) ?? 'Unknown User';
          final raterAvatarUrl = (raterMap['avatar_url'] as String?) ?? '';

          // Convert raw DB map to fully enriched Review domain model.
          final review = Review.fromMap(
            reviewMap,
            raterName: raterName,
            raterAvatarUrl: raterAvatarUrl,
          );

          assembledReviews.add(review);
          totalRating += review.ratingValue;

          // Aggregate distribution only for valid rating ranges.
          final ratingKey = review.ratingValue.toInt();
          if (ratingKey >= 1 && ratingKey <= 5) {
            distribution[ratingKey] = (distribution[ratingKey] ?? 0) + 1;
          }
        }
      }

      final totalReviews = assembledReviews.length;
      final averageRating = totalReviews > 0 ? totalRating / totalReviews : 0.0;

      // Emit successfully processed results.
      emit(
        ReviewsLoaded(
          averageRating: averageRating,
          totalReviews: totalReviews,
          ratingDistribution: distribution,
          // Date sorting assumes ISO-8601 timestamps for deterministic ordering.
          reviews: assembledReviews
            ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated)),
        ),
      );
    } catch (e) {
      // Fail gracefully with a diagnosable error state.
      emit(ReviewsError('Failed to load reviews: ${e.toString()}'));
    }
  }
}
