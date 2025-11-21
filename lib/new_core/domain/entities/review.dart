import 'package:equatable/equatable.dart';

import '../value_objects/rating.dart';

class Review extends Equatable {
  final String id;
  final String orderId;
  final String reviewerId;
  final String reviewedUserId;
  final Rating rating;
  final String? comment;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  bool get hasComment => comment != null && comment!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    orderId,
    reviewerId,
    reviewedUserId,
    rating,
    comment,
    timestamp,
  ];
}
