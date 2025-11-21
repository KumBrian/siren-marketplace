import 'package:equatable/equatable.dart';

/// Represents a rating value (1-5 stars)
class Rating extends Equatable {
  final double value;

  const Rating._(this.value);

  factory Rating.fromValue(double value) {
    if (value < 0 || value > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }
    return Rating._(value);
  }

  factory Rating.zero() => const Rating._(0.0);

  bool get isZero => value == 0.0;

  bool get hasRating => value > 0.0;

  int get fullStars => value.floor();

  bool get hasHalfStar => (value - fullStars) >= 0.5;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toStringAsFixed(1);
}
