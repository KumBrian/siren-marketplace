import 'package:equatable/equatable.dart';

import 'price.dart';
import 'price_per_kg.dart';
import 'weight.dart';

/// Encapsulates the financial terms of an offer.
/// Ensures consistency between price, weight, and pricePerKg.
class OfferTerms extends Equatable {
  final Price totalPrice;
  final Weight weight;
  final PricePerKg pricePerKg;

  const OfferTerms._({
    required this.totalPrice,
    required this.weight,
    required this.pricePerKg,
  });

  /// Create offer terms with automatic pricePerKg calculation
  factory OfferTerms.create({
    required Price totalPrice,
    required Weight weight,
  }) {
    final pricePerKg = PricePerKg.calculate(
      totalPrice: totalPrice,
      weight: weight,
    );

    return OfferTerms._(
      totalPrice: totalPrice,
      weight: weight,
      pricePerKg: pricePerKg,
    );
  }

  /// Create from pricePerKg and weight (calculates total)
  factory OfferTerms.fromPricePerKg({
    required PricePerKg pricePerKg,
    required Weight weight,
  }) {
    final totalPrice = pricePerKg.calculateTotalPrice(weight);

    return OfferTerms._(
      totalPrice: totalPrice,
      weight: weight,
      pricePerKg: pricePerKg,
    );
  }

  bool isDifferentFrom(OfferTerms other) {
    return totalPrice != other.totalPrice || weight != other.weight;
  }

  @override
  List<Object?> get props => [totalPrice, weight, pricePerKg];

  @override
  String toString() =>
      'OfferTerms(total: $totalPrice, weight: $weight, pricePerKg: $pricePerKg)';
}
