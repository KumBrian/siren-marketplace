part of 'reviews_cubit.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  // Aggregate data
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: count, 4: count, ...}

  // Individual reviews
  final List<Review> reviews;

  const ReviewsLoaded({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.reviews,
  });

  @override
  List<Object> get props => [
    averageRating,
    totalReviews,
    ratingDistribution,
    reviews,
  ];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object> get props => [message];
}
