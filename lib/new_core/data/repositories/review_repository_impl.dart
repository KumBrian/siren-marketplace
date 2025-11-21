import '../../domain/entities/review.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../datasources/interfaces/i_review_datasource.dart';
import '../mappers/review_mapper.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final IReviewDataSource dataSource;

  ReviewRepositoryImpl({required this.dataSource});

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
    final models = await dataSource.getReviewsForUser(userId);
    return models.map((m) => ReviewMapper.toEntity(m)).toList();
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
  Future<void> delete(String reviewId) async {
    await dataSource.delete(reviewId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }
}
