import '../entities/order.dart';
import '../entities/review.dart';
import '../repositories/i_order_repository.dart';
import '../repositories/i_review_repository.dart';
import '../repositories/i_user_repository.dart';
import '../value_objects/rating.dart';

/// Service handling review submission and rating calculations
class RatingService {
  final IReviewRepository _reviewRepository;
  final IOrderRepository _orderRepository;
  final IUserRepository _userRepository;

  RatingService({
    required IReviewRepository reviewRepository,
    required IOrderRepository orderRepository,
    required IUserRepository userRepository,
  }) : _reviewRepository = reviewRepository,
       _orderRepository = orderRepository,
       _userRepository = userRepository;

  /// Submit a review for an order
  Future<Review> submitReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  }) async {
    // Validate order exists and is completed
    final order = await _orderRepository.getById(orderId);
    if (order == null) {
      throw ArgumentError('Order not found');
    }

    if (!order.canBeReviewedBy(reviewerId)) {
      throw StateError('Order cannot be reviewed by this user');
    }

    // Check if already reviewed
    final hasExisting = await _reviewRepository.hasReview(
      orderId: orderId,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
    );

    if (hasExisting) {
      throw StateError('Review already submitted for this order');
    }

    // Execute in transaction
    return await _reviewRepository.transaction(() async {
      // Create review
      final review = Review(
        id: _generateId(),
        orderId: orderId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
      );

      await _reviewRepository.create(review);

      // Update order review status
      final updatedOrder = order.markAsReviewedBy(reviewerId);
      await _orderRepository.update(updatedOrder);

      // Recalculate user's aggregate rating
      await _updateUserAggregateRating(reviewedUserId);

      return review;
    });
  }

  /// Get all reviews for a user
  Future<List<Review>> getReviewsForUser(String userId) async {
    return await _reviewRepository.getReviewsForUser(userId);
  }

  /// Get orders that can be reviewed by user
  Future<List<Order>> getReviewableOrders(String userId) async {
    return await _orderRepository.getReviewableOrders(userId);
  }

  /// Recalculate and update user's aggregate rating
  Future<void> _updateUserAggregateRating(String userId) async {
    final reviews = await _reviewRepository.getReviewsForUser(userId);

    if (reviews.isEmpty) {
      await _userRepository.updateRating(
        userId: userId,
        rating: Rating.zero(),
        reviewCount: 0,
      );
      return;
    }

    final totalRating = reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating.value,
    );

    final averageRating = Rating.fromValue(totalRating / reviews.length);

    await _userRepository.updateRating(
      userId: userId,
      rating: averageRating,
      reviewCount: reviews.length,
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
