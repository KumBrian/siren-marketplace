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

List<HistoricalPriceData> _generateData(
  String species,
  double baseValue, {
  bool isCatch = false,
}) {
  final data = <HistoricalPriceData>[];
  final speciesSeed =
      baseValue / 100.0; // Use base price to make randomness unique per species

  // 1. Generate Hourly Data (Last 24 Hours)
  for (int i = 0; i < 24; i++) {
    final hoursAgo = i;
    final date = now.subtract(Duration(hours: hoursAgo));

    // Intra-day volatility
    final volatility =
        _random.nextDouble() * (baseValue * 0.05) - (baseValue * 0.025);
    final noise =
        _getDeterministicNoise(hoursAgo, speciesSeed) * (isCatch ? 1 : 2);

    double value = baseValue + noise + volatility;
    value = double.parse(value.clamp(0.0, 10000.0).toStringAsFixed(2));

    data.add(
      HistoricalPriceData(species: species, date: date, pricePerKg: value),
    );
  }

  // 2. Generate Daily Data (Last 30 Days)
  for (int i = 1; i < 30; i++) {
    final daysAgo = i;
    final date = now.subtract(Duration(days: daysAgo));

    final dailyVolatility =
        _random.nextDouble() * (baseValue * 0.1) - (baseValue * 0.05);
    final marketNoise = _getDeterministicNoise(daysAgo, speciesSeed) * 5;

    double value = baseValue + marketNoise + dailyVolatility;
    value = double.parse(value.clamp(0.0, 10000.0).toStringAsFixed(2));

    data.add(
      HistoricalPriceData(species: species, date: date, pricePerKg: value),
    );
  }

  // 3. Generate Monthly Data (Last 12 Months)
  for (int i = 30; i < 365; i += 30) {
    final daysAgo = i;
    final date = now.subtract(Duration(days: daysAgo));

    final longTermTrend = (365 - daysAgo) / 365.0 * (baseValue * 0.1);
    final marketNoise = _getDeterministicNoise(daysAgo, speciesSeed) * 2;

    double value = (baseValue * 0.9) + longTermTrend + marketNoise;
    value = double.parse(value.clamp(0.0, 10000.0).toStringAsFixed(2));

    data.add(
      HistoricalPriceData(species: species, date: date, pricePerKg: value),
    );
  }

  return data;
}

final List<HistoricalPriceData> mockHistoricalPrices = [
  ..._generateData('pink-shrimp', 1100.0),
  ..._generateData('tiger-shrimp', 1400.0),
  ..._generateData('gray-shrimp', 950.0),
  ..._generateData('small-prawn', 350.0),
  ..._generateData('large-prawn', 750.0),
];

final List<HistoricalPriceData> mockHistoricalCatches = [
  ..._generateData('pink-shrimp', 150.0, isCatch: true),
  ..._generateData('tiger-shrimp', 80.0, isCatch: true),
  ..._generateData('gray-shrimp', 200.0, isCatch: true),
  ..._generateData('small-prawn', 400.0, isCatch: true),
  ..._generateData('large-prawn', 120.0, isCatch: true),
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
