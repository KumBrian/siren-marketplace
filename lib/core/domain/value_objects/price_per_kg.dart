import 'package:equatable/equatable.dart';

import 'price.dart';
import 'weight.dart';

/// Represents price per kilogram.
/// Automatically calculated from total price and weight.
class PricePerKg extends Equatable {
  final int amountPerKg; // price per kg in smallest currency unit

  const PricePerKg._(this.amountPerKg);

  factory PricePerKg.fromAmount(int amountPerKg) {
    if (amountPerKg < 0) {
      throw ArgumentError('Price per kg cannot be negative');
    }
    return PricePerKg._(amountPerKg);
  }

  /// Calculate price per kg from total price and weight
  factory PricePerKg.calculate({
    required Price totalPrice,
    required Weight weight,
  }) {
    if (weight.isZero) {
      // Avoid division by zero, return 0 instead of throwing
      // This handles cases where data might be incomplete during transitions
      return const PricePerKg._(0);
    }

    // Formula: (Total Price * 1000) / Weight in Grams
    final pricePerKg = ((totalPrice.amount * 1000) / weight.grams).round();
    return PricePerKg._(pricePerKg);
  }

  double get major => amountPerKg / 100.0;

  /// Calculate total price for a given weight
  Price calculateTotalPrice(Weight weight) {
    final totalAmount = (amountPerKg * weight.grams / 1000).round();
    return Price.fromAmount(totalAmount);
  }

  @override
  List<Object?> get props => [amountPerKg];

  @override
  String toString() => '\$${major.toStringAsFixed(2)}/kg';

  int compareTo(PricePerKg priceB) {
    return amountPerKg.compareTo(priceB.amountPerKg);
  }
}
