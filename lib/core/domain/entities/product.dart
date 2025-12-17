import 'package:equatable/equatable.dart';

import '../value_objects/price.dart';
import '../value_objects/price_per_kg.dart';
import '../value_objects/weight.dart';
import 'species.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String marketName;
  final String status;
  final PricePerKg pricePerKg;
  final Price totalPrice;
  final Weight initialWeight;
  final Weight availableWeight;
  final String size;
  final DateTime datePosted;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime? soldAt;
  final bool isSold;
  // Gear Info
  final double? meshSize;
  final double? gearLength;
  final double? gearWidth;
  final String? gearNature;
  final Species species;

  const Product({
    required this.id,
    required this.name,
    required this.marketName,
    required this.status,
    required this.pricePerKg,
    required this.totalPrice,
    required this.initialWeight,
    required this.availableWeight,
    required this.size,
    required this.datePosted,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.soldAt,
    this.isSold = false,
    this.meshSize,
    this.gearLength,
    this.gearWidth,
    this.gearNature,
    required this.species,
  });

  bool get isExpired {
    // Assuming same logic as Catch for now, or maybe product has expire_at from API
    // API response has "expire_at"
    return false; // TODO: Implement expiration logic if needed based on expire_at
  }

  // Helpers for UI (similar to Catch)
  int get daysLeft {
    // API provides 'expire_at', we should probably use that.
    // For now, let's just use datePosted + 7 days like Catch if expire_at logic is complex,
    // but the API response has "expire_at": "2025-12-09T12:00:00+00:00"
    // Let's defer exact logic to mapper/entity refinement.
    // However, ForSaleCard uses daysLeftLabel.

    // For now simple implementation based on Catch logic:
    final expirationDate = datePosted.add(const Duration(days: 7));
    final diff = expirationDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  String get daysLeftLabel {
    final left = daysLeft;
    if (left == 0) return "Expired";
    if (left == 1) return "1 day left";
    return "$left days left";
  }

  @override
  List<Object?> get props => [
    id,
    name,
    marketName,
    status,
    pricePerKg,
    totalPrice,
    initialWeight,
    availableWeight,
    size,
    datePosted,
    locationName,
    latitude,
    longitude,
    soldAt,
    isSold,
    meshSize,
    gearLength,
    gearWidth,
    gearNature,
    species,
  ];
}
