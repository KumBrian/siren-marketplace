import 'package:intl/intl.dart';

import '../domain/entities/catch.dart';
import '../domain/entities/offer.dart';
import '../domain/entities/order.dart';
import '../domain/entities/user.dart';

/// Adapters to make new Domain Entities look like old Models for UI compatibility.
/// This allows us to migrate BLoCs without rewriting the entire UI widget tree.

extension CatchAdapter on Catch {
  // Map new ValueObjects to old primitive types
  int get pricePerKgInt => pricePerKg.amountPerKg;

  int get availableWeightInt => availableWeight.grams;

  int get totalInt => totalPrice.amount;

  // Date formatting to match old String date
  String get datePostedString => datePosted.toIso8601String();

  // Status display
  String get statusName => status.name;

  // Helper for display
  String get formattedPrice => '\$${totalPrice.major.toStringAsFixed(2)}';

  String get formattedPricePerKg =>
      '\$${pricePerKg.major.toStringAsFixed(2)}/kg';

  String get formattedWeight =>
      '${availableWeight.kilograms.toStringAsFixed(1)}kg';
}

extension OfferAdapter on Offer {
  // Map terms to old flat properties
  int get priceInt => currentTerms.totalPrice.amount;

  int get weightInt => currentTerms.weight.grams;

  int get pricePerKgInt => currentTerms.pricePerKg.amountPerKg;

  // Previous terms
  int? get previousPriceInt => previousTerms?.totalPrice.amount;

  int? get previousWeightInt => previousTerms?.weight.grams;

  int? get previousPricePerKgInt => previousTerms?.pricePerKg.amountPerKg;

  // Status
  String get statusName => status.name;

  // Display helpers
  String get formattedPrice =>
      '\$${currentTerms.totalPrice.major.toStringAsFixed(2)}';

  String get formattedWeight =>
      '${currentTerms.weight.kilograms.toStringAsFixed(1)}kg';
}

extension OrderAdapter on Order {
  // Map terms
  int get priceInt => terms.totalPrice.amount;

  int get weightInt => terms.weight.grams;

  // Status
  String get statusName => status.name;

  // Display helpers
  String get formattedPrice => '\$${terms.totalPrice.major.toStringAsFixed(2)}';

  String get formattedDate => DateFormat('MMM d, y').format(dateCreated);
}

extension UserAdapter on User {
  // Map properties
  double get ratingValue => rating.value;

  String get roleName => currentRole.name;

  // Display helpers
  String get formattedRating => rating.value.toStringAsFixed(1);
}
