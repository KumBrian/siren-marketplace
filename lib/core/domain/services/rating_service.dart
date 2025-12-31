import '../entities/order.dart';
import '../entities/review.dart';
import '../repositories/i_order_repository.dart';
import '../repositories/i_review_repository.dart';

import '../value_objects/rating.dart';

/// Service handling review submission and rating calculations
class RatingService {
  final IReviewRepository _reviewRepository;
  final IOrderRepository _orderRepository;

  RatingService({
    required IReviewRepository reviewRepository,
    required IOrderRepository orderRepository,
  }) : _reviewRepository = reviewRepository,
       _orderRepository = orderRepository;

  /// Submit a review for an order
  Future<Review> submitReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  }) async {
    // Validate order exists and can be reviewed (optional, as API handles this too)
    // We keep local validation for immediate feedback if data is available

    return await _reviewRepository.submitReview(
      orderId: orderId,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
      rating: rating,
      comment: comment,
    );
  }

  /// Get all reviews for a user
  Future<List<Review>> getReviewsForUser(String userId) async {
    return await _reviewRepository.getReviewsForUser(userId);
  }

  /// Get orders that can be reviewed by user
  Future<List<Order>> getReviewableOrders(String userId) async {
    return await _orderRepository.getReviewableOrders(userId);
  }
}
