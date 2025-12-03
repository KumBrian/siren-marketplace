import 'package:equatable/equatable.dart';

/// Represents a price in the marketplace.
/// Stored as integer (smallest currency unit, e.g., cents)
class Price extends Equatable {
  final int amount; // in smallest currency unit

  const Price._(this.amount);

  factory Price.fromAmount(int amount) {
    if (amount < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    return Price._(amount);
  }

  /// Create from major currency units (e.g., dollars)
  factory Price.fromMajor(double major) {
    if (major < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    return Price._((major * 100).round());
  }

  double get major => amount / 100.0;

  bool get isZero => amount == 0;

  bool get isPositive => amount > 0;

  Price operator +(Price other) => Price._(amount + other.amount);

  Price operator -(Price other) {
    if (amount < other.amount) {
      throw ArgumentError('Result would be negative');
    }
    return Price._(amount - other.amount);
  }

  Price operator *(int multiplier) => Price._(amount * multiplier);

  bool operator >(Price other) => amount > other.amount;

  bool operator <(Price other) => amount < other.amount;

  bool operator >=(Price other) => amount >= other.amount;

  bool operator <=(Price other) => amount <= other.amount;

  @override
  List<Object?> get props => [amount];

  @override
  String toString() => '\$${major.toStringAsFixed(2)}';
}
