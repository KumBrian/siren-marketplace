import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String orderId;
  final String raterId;
  final String ratedUserId;
  final double ratingValue;
  final String? message;
  final String dateCreated; // Reverted back to String

  // Details of the user who submitted the review (Rater)
  final String raterName;
  final String raterAvatarUrl;

  const Review({
    required this.id,
    required this.orderId,
    required this.raterId,
    required this.ratedUserId,
    required this.ratingValue,
    required this.dateCreated,
    required this.raterName,
    required this.raterAvatarUrl,
    this.message,
  });

  // Factory to create from a database map (requires rater details to be pre-fetched)
  factory Review.fromMap(
    Map<String, dynamic> map, {
    required String raterName,
    required String raterAvatarUrl,
  }) {
    // The date can come from 'date_created' or 'timestamp' depending on your database layer
    final dateString =
        map['date_created'] as String? ?? map['timestamp'] as String? ?? 'N/A';

    return Review(
      id: map['rating_id'] as String? ?? map['id'] as String,
      // Safe access
      orderId: map['order_id'] as String,
      raterId: map['rater_id'] as String,
      ratedUserId: map['rated_user_id'] as String,
      ratingValue: (map['rating_value'] as num).toDouble(),
      message: map['message'] as String?,
      dateCreated: dateString,
      // Stays as String
      raterName: raterName,
      raterAvatarUrl: raterAvatarUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    raterId,
    ratedUserId,
    ratingValue,
    message,
    dateCreated,
    raterName,
    raterAvatarUrl,
  ];
}
