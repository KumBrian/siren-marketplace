import 'package:flutter/cupertino.dart';
import 'package:siren_marketplace/core/models/species.dart';

class AppSpacing {
  //SIREN PADDING
  static const padding10 = 10.0;
  static const padding15 = 15.0;
  static const padding20 = 20.0;
  static const padding25 = 25.0;
  static const padding30 = 30.0;
  static const padding35 = 35.0;
  static const padding40 = 40.0;

  //SIREN MARGIN
  static const margin10 = 10.0;
  static const margin15 = 15.0;
  static const margin20 = 20.0;
  static const margin25 = 25.0;
  static const margin30 = 30.0;
  static const margin35 = 35.0;
  static const margin40 = 40.0;
}

const List<Species> kSpecies = [
  Species(id: "tiger-shrimp", name: "Tiger Shrimp"),
  Species(id: "pink-shrimp", name: "Pink Shrimp"),
  Species(id: "grey-shrimp", name: "Grey Shrimp"),
  Species(id: "small-prawn", name: "Small Prawn"),
  Species(id: "large-prawn", name: "Large Prawn"),
];

const List<String> kFailedTransactionReasons = [
  "Buyer did not come to collect the order",
  "Disagreement on the final price.",
  "Product already sold elsewhere.",
];

double calculatePricePerKg(
  TextEditingController weightController,
  TextEditingController priceController,
) {
  final weightText = weightController.text;
  final priceText = priceController.text;

  // Attempt to parse input values
  final weight = double.tryParse(weightText);
  final price = double.tryParse(priceText);

  double newPricePerKg = 0.0;

  // Ensure both values are valid numbers and weight is not zero
  if (weight != null && price != null && weight > 0) {
    newPricePerKg = price / weight;
  }
  return newPricePerKg;
}
