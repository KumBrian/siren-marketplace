import '../../domain/entities/review.dart';
import '../../domain/value_objects/rating.dart';
import '../models/review_model.dart';
import '../api/models/review_api_models.dart';

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
      reviewerName: entity.reviewerName,
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
      reviewerName: model.reviewerName ?? 'Unknown',
    );
  }

  /// Convert API response to domain entity
  static Review fromApi(ReviewApiResponse api) {
    return Review(
      id: api.uid ?? api.id.toString(),
      orderId: api.saleOrder?.toString() ?? '',
      reviewerId: api.reviewer?.id?.toString() ?? '',
      reviewedUserId: api.reviewedAccount?.id?.toString() ?? '',
      rating: Rating.fromValue(api.rate),
      comment: api.message,
      timestamp: api.createdAt != null
          ? DateTime.tryParse(api.createdAt!) ?? DateTime.now()
          : DateTime.now(),
      reviewerName: api.reviewer != null
          ? '${api.reviewer!.firstName ?? ''} ${api.reviewer!.lastName ?? ''}'
                .trim()
          : (api.reviewer?.username ?? 'Unknown'),
    );
  }
}
