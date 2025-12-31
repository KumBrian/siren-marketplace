import '../entities/review.dart';
import '../value_objects/rating.dart';

abstract class IReviewRepository {
  /// Create a new review
  Future<String> create(Review review);

  /// Submit a review via API
  Future<Review> submitReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  });

  /// Get review by ID
  Future<Review?> getById(String reviewId);

  /// Get all reviews for a specific user
  Future<List<Review>> getReviewsForUser(String userId);

  /// Get all reviews written by a user
  Future<List<Review>> getReviewsByUser(String userId);

  /// Get review for a specific order
  Future<List<Review>> getReviewsForOrder(String orderId);

  /// Check if review exists for order and reviewer
  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  });

  /// Delete review
  Future<void> delete(String reviewId);

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function() action);
}
