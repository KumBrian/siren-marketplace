import '../../domain/entities/review.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../datasources/interfaces/i_review_datasource.dart';
import '../mappers/review_mapper.dart';
import '../datasources/api/reviews_api_data_source.dart';
import '../api/models/review_api_models.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import '../../domain/value_objects/rating.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final IReviewDataSource dataSource;
  final ReviewsApiDataSource? apiDataSource;
  final ConnectivityService? connectivityService;

  ReviewRepositoryImpl({
    required this.dataSource,
    this.apiDataSource,
    this.connectivityService,
  });

  Future<bool> get _isOffline async {
    if (connectivityService == null) return false;
    return !(await connectivityService!.hasConnection);
  }

  Future<List<Review>> _getLocalReviews(String userId) async {
    final models = await dataSource.getReviewsForUser(userId);
    return models.map((m) => ReviewMapper.toEntity(m)).toList();
  }

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
    // 1. Check Offline
    if (await _isOffline) {
      return _getLocalReviews(userId);
    }

    if (apiDataSource != null) {
      try {
        // Parse userId to int for API call
        final accountId = int.parse(userId);
        final response = await apiDataSource!.getReviewsForAccount(accountId);

        final reviews = response.map((r) => ReviewMapper.fromApi(r)).toList();

        // 3. Cache to Local
        for (var review in reviews) {
          await dataSource.create(ReviewMapper.toModel(review));
        }

        return reviews;
      } catch (e) {
        print('Error fetching reviews via API: $e');
        // 4. Fallback to Local
        return _getLocalReviews(userId);
      }
    }

    // Default/Local-only mode
    return _getLocalReviews(userId);
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
            rating: Rating.fromValue(r.rate.toDouble()),
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
        rating: Rating.fromValue(response.rate.toDouble()),
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
