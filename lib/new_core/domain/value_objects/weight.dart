import 'package:equatable/equatable.dart';

/// Represents a weight measurement in the marketplace.
/// Internally stores weight in GRAMS for precision.
class Weight extends Equatable {
  final int grams;

  const Weight._(this.grams);

  /// Create from grams
  factory Weight.fromGrams(int grams) {
    if (grams < 0) {
      throw ArgumentError('Weight cannot be negative');
    }
    return Weight._(grams);
  }

  /// Create from kilograms
  factory Weight.fromKg(double kg) {
    if (kg < 0) {
      throw ArgumentError('Weight cannot be negative');
    }
    return Weight._((kg * 1000).round());
  }

  double get kilograms => grams / 1000.0;

  bool get isZero => grams == 0;

  bool get isPositive => grams > 0;

  Weight operator +(Weight other) => Weight._(grams + other.grams);

  Weight operator -(Weight other) {
    if (grams < other.grams) {
      throw ArgumentError('Result would be negative');
    }
    return Weight._(grams - other.grams);
  }

  bool operator >(Weight other) => grams > other.grams;

  bool operator <(Weight other) => grams < other.grams;

  bool operator >=(Weight other) => grams >= other.grams;

  bool operator <=(Weight other) => grams <= other.grams;

  @override
  List<Object?> get props => [grams];

  @override
  String toString() => '${kilograms.toStringAsFixed(2)} kg';
}
