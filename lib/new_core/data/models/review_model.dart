class ReviewModel {
  final String id;
  final String orderId;
  final String reviewerId;
  final String reviewedUserId;
  final double ratingValue;
  final String? comment;
  final String timestamp; // ISO8601

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.ratingValue,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'reviewer_id': reviewerId,
    'reviewed_user_id': reviewedUserId,
    'rating_value': ratingValue,
    'comment': comment,
    'timestamp': timestamp,
  };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    reviewerId: json['reviewer_id'] as String,
    reviewedUserId: json['reviewed_user_id'] as String,
    ratingValue: (json['rating_value'] as num).toDouble(),
    comment: json['comment'] as String?,
    timestamp: json['timestamp'] as String,
  );

  // SQLite mapping
  Map<String, dynamic> toMap() => {
    'rating_id': id,
    'order_id': orderId,
    'rater_id': reviewerId,
    'rated_user_id': reviewedUserId,
    'rating_value': ratingValue,
    'message': comment,
    'timestamp': timestamp,
  };

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id: map['rating_id'] as String,
    orderId: map['order_id'] as String,
    reviewerId: map['rater_id'] as String,
    reviewedUserId: map['rated_user_id'] as String,
    ratingValue: (map['rating_value'] as num).toDouble(),
    comment: map['message'] as String?,
    timestamp: map['timestamp'] as String,
  );
}
