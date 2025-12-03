import '../../models/review_model.dart';

abstract class IReviewDataSource {
  Future<String> create(ReviewModel review);

  Future<ReviewModel?> getById(String reviewId);

  Future<List<ReviewModel>> getReviewsForUser(String userId);

  Future<List<ReviewModel>> getReviewsByUser(String userId);

  Future<List<ReviewModel>> getReviewsForOrder(String orderId);

  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  });

  Future<void> delete(String reviewId);

  // Transaction support
  Future<T> transaction<T>(Future<T> Function() action);
}
