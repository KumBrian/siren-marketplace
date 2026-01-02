import '../../domain/entities/review.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../datasources/interfaces/i_review_datasource.dart';
import '../mappers/review_mapper.dart';
import '../datasources/api/reviews_api_data_source.dart';
import '../api/models/review_api_models.dart';
import '../../domain/value_objects/rating.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final IReviewDataSource dataSource;
  final ReviewsApiDataSource? apiDataSource;

  ReviewRepositoryImpl({required this.dataSource, this.apiDataSource});

  @override
  Future<String> create(Review review) async {
    final model = ReviewMapper.toModel(review);
    return await dataSource.create(model);
  }

  @override
  Future<Review?> getById(String reviewId) async {
    final model = await dataSource.getById(reviewId);
    return model != null ? ReviewMapper.toEntity(model) : null;
  }

  @override
  Future<List<Review>> getReviewsForUser(String userId) async {
    if (apiDataSource != null) {
      try {
        // Parse userId to int for API call (User entity id is String but holds int value)
        final accountId = int.parse(userId);
        final response = await apiDataSource!.getReviewsForAccount(accountId);

        return response.map((r) {
          // Convert ReviewApiResponse to Review entity
          return Review(
            id: r.id.toString(),
            orderId: r.saleOrder?.toString() ?? '',
            reviewerId: r.reviewer?.id?.toString() ?? '',
            reviewedUserId: r.reviewedAccount?.id?.toString() ?? '',
            rating: Rating.fromValue(r.rate),
            comment: r.message,
            timestamp: r.createdAt != null
                ? DateTime.parse(r.createdAt!)
                : DateTime.now(),
            reviewerName: r.reviewer != null
                ? '${r.reviewer!.firstName ?? ''} ${r.reviewer!.lastName ?? ''}'
                      .trim()
                : 'Unknown',
          );
        }).toList();
      } catch (e) {
        print('Error fetching reviews via API: $e');
        // Fallback to local data source or rethrow?
        // For now, let's try local data source as fallback or empty list
        return [];
      }
    }

    final models = await dataSource.getReviewsForUser(userId);
    return models.map((m) => ReviewMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Review>> getMyReviews() async {
    if (apiDataSource != null) {
      try {
        final response = await apiDataSource!.getMyReviews();

        return response.map((r) {
          // Convert ReviewApiResponse to Review entity
          return Review(
            id: r.id.toString(),
            orderId: r.saleOrder?.toString() ?? '',
            reviewerId: r.reviewer?.id?.toString() ?? '',
            reviewedUserId: r.reviewedAccount?.id?.toString() ?? '',
            rating: Rating.fromValue(r.rate),
            comment: r.message,
            timestamp: r.createdAt != null
                ? DateTime.parse(r.createdAt!)
                : DateTime.now(),
            reviewerName: r.reviewer != null
                ? '${r.reviewer!.firstName ?? ''} ${r.reviewer!.lastName ?? ''}'
                      .trim()
                : 'Unknown',
          );
        }).toList();
      } catch (e) {
        print('Error fetching my reviews via API: $e');
        return [];
      }
    }
    return [];
  }

  @override
  Future<List<Review>> getReviewsByUser(String userId) async {
    final models = await dataSource.getReviewsByUser(userId);
    return models.map((m) => ReviewMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Review>> getReviewsForOrder(String orderId) async {
    final models = await dataSource.getReviewsForOrder(orderId);
    return models.map((m) => ReviewMapper.toEntity(m)).toList();
  }

  @override
  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  }) async {
    return await dataSource.hasReview(
      orderId: orderId,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
    );
  }

  @override
  Future<Review> submitReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
    required Rating rating,
    String? comment,
  }) async {
    if (apiDataSource != null) {
      final request = ReviewApiRequest(
        saleOrder: int.parse(orderId),
        rate: rating.value,
        message: comment ?? '',
        published: true,
      );
      final response = await apiDataSource!.create(request);

      // Convert response to Review entity
      return Review(
        id: response.id.toString(),
        orderId: orderId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: Rating.fromValue(response.rate),
        comment: response.message,
        timestamp: response.createdAt != null
            ? DateTime.parse(response.createdAt!)
            : DateTime.now(),
      );
    } else {
      // Fallback for local/demo mode
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: orderId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
      );

      await create(review);
      return review;
    }
  }

  @override
  Future<void> delete(String reviewId) async {
    await dataSource.delete(reviewId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }
}
