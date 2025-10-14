import 'dart:math';

import 'package:siren_marketplace/core/types/enum.dart'; // Required for generating random numbers

/// Represents a single historical price point for a species.
class HistoricalPriceData {
  const HistoricalPriceData({
    required this.species,
    required this.date,
    required this.pricePerKg,
  });

  final String species;
  final DateTime date;
  final double pricePerKg;
}

// --- MOCK DATA SOURCE ---

final now = DateTime.now();
final _random = Random();

// Helper function to get a consistent random seed for each species/date combination
double _getDeterministicNoise(int daysAgo, double seed) {
  // Use sin and cos to introduce cyclic, but non-linear, variation
  // Multiplied by a random factor based on the seed
  return (sin(daysAgo / 7.0) * cos(daysAgo / 30.0) * 10) +
      (_random.nextDouble() * seed - seed / 2);
}

List<HistoricalPriceData> _generateSpeciesData(
  String species,
  double initialBasePrice,
) {
  final data = <HistoricalPriceData>[];
  final speciesSeed =
      initialBasePrice /
      100.0; // Use base price to make randomness unique per species

  // 1. Generate Daily Data (Last 30 Days) - High Volatility
  for (int i = 0; i < 30; i++) {
    final daysAgo = i;
    final date = now.subtract(Duration(days: daysAgo));

    // Simulate high daily volatility (e.g., +/- 50 CFA)
    final dailyVolatility = _random.nextDouble() * 100 - 50;

    // Smooth, species-specific market noise
    final marketNoise = _getDeterministicNoise(daysAgo, speciesSeed) * 5;

    // Calculate final price
    double price = initialBasePrice + marketNoise + dailyVolatility;

    // Ensure the price is always positive and format to 2 decimal places
    price = double.parse(price.clamp(100.0, 5000.0).toStringAsFixed(2));

    data.add(
      HistoricalPriceData(species: species, date: date, pricePerKg: price),
    );
  }

  // 2. Generate Monthly Data (Last 12 Months) - Lower Volatility, Clearer Trend
  for (int i = 30; i < 365; i += 30) {
    final daysAgo = i;
    final date = now.subtract(Duration(days: daysAgo));

    // Simulate seasonal or long-term trend (e.g., lower prices further back)
    final longTermTrend = (365 - daysAgo) / 365.0 * 50.0;

    // Less volatility for long-term trends
    final marketNoise = _getDeterministicNoise(daysAgo, speciesSeed) * 2;

    double price = (initialBasePrice * 0.9) + longTermTrend + marketNoise;

    price = double.parse(price.clamp(100.0, 5000.0).toStringAsFixed(2));

    data.add(
      HistoricalPriceData(species: species, date: date, pricePerKg: price),
    );
  }

  return data;
}

final List<HistoricalPriceData> mockHistoricalPrices = [
  // Pink Shrimp (Initial Base Price around 1100)
  ..._generateSpeciesData('pink-shrimp', 1100.0),

  // Tiger Shrimp (Initial Base Price around 1400)
  ..._generateSpeciesData('tiger-shrimp', 1400.0),

  // Grey Shrimp (Initial Base Price around 950)
  ..._generateSpeciesData('gray-shrimp', 950.0),
];

// --- DATA FILTERING LOGIC ---

DateTime _getStartDate(dynamic range) {
  final now = DateTime.now();
  switch (range) {
    case ChartRange.day:
      // Last 24 hours
      return now.subtract(const Duration(days: 1));
    case ChartRange.week:
      // Last 7 days
      return now.subtract(const Duration(days: 7));
    case ChartRange.month:
      // Last 30 days
      return now.subtract(const Duration(days: 30));
    case ChartRange.year:
      // Last 365 days
      return now.subtract(const Duration(days: 365));
    default:
      return now.subtract(const Duration(days: 30));
  }
}

List<HistoricalPriceData> filterDataByRange(
  List<HistoricalPriceData> data,
  dynamic range,
) {
  // 1. Calculate the required start date based on the pill selection
  final startDate = _getStartDate(range);

  // 2. Filter the mock data: only include dates strictly after the start date
  return data.where((d) => d.date.isAfter(startDate)).toList();
}
