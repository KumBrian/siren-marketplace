import '../../domain/entities/review.dart';
import '../../domain/value_objects/rating.dart';
import '../models/review_model.dart';

class ReviewMapper {
  /// Convert domain entity to data model
  static ReviewModel toModel(Review entity) {
    return ReviewModel(
      id: entity.id,
      orderId: entity.orderId,
      reviewerId: entity.reviewerId,
      reviewedUserId: entity.reviewedUserId,
      ratingValue: entity.rating.value,
      comment: entity.comment,
      timestamp: entity.timestamp.toIso8601String(),
    );
  }

  /// Convert data model to domain entity
  static Review toEntity(ReviewModel model) {
    return Review(
      id: model.id,
      orderId: model.orderId,
      reviewerId: model.reviewerId,
      reviewedUserId: model.reviewedUserId,
      rating: Rating.fromValue(model.ratingValue),
      comment: model.comment,
      timestamp: DateTime.parse(model.timestamp),
    );
  }
}
