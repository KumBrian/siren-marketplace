import 'package:equatable/equatable.dart';

import '../types/converters.dart'
    show offerStatusFromString, offerStatusToString;
import '../types/enum.dart' show OfferStatus;

class Offer extends Equatable {
  final String id;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final double pricePerKg;
  final double price;
  final double weight;
  final OfferStatus status;
  final String dateCreated;
  final double? previousPrice;
  final double? previousWeight;
  final double? previousPricePerKg;

  // 🆕 ADDED FIELD
  final bool hasUpdateForFisher;
  final bool hasUpdateForBuyer;

  // Denormalized fields
  final String catchName;
  final String catchImageUrl;
  final String fisherName;
  final double fisherRating;
  final String fisherAvatarUrl;
  final String buyerName;
  final double buyerRating;
  final String buyerAvatarUrl;

  const Offer({
    // Core fields, required for any offer
    required this.id,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.pricePerKg,
    required this.price,
    required this.weight,
    required this.status,
    required this.dateCreated,
    // 🆕 ADDED FIELD WITH DEFAULT
    this.hasUpdateForBuyer = true, // Default to true for new offers
    this.hasUpdateForFisher = true, // Default to true for new offers
    // Denormalized fields, provide defaults or make optional if not always available
    this.catchName = '', // Default to empty string
    this.catchImageUrl = '', // Default to empty string
    this.fisherName = '', // Default to empty string
    this.fisherRating = 0.0, // Default to 0.0
    this.fisherAvatarUrl = '', // Default to empty string
    this.buyerName = '', // Default to empty string
    this.buyerRating = 0.0, // Default to 0.0
    this.buyerAvatarUrl = '', // Default to empty string
    // Previous fields, already optional
    this.previousPrice,
    this.previousWeight,
    this.previousPricePerKg,
  });

  @override
  List<Object?> get props => [
    id,
    catchId,
    fisherId,
    buyerId,
    pricePerKg,
    price,
    weight,
    status,
    dateCreated,
    previousPrice,
    previousWeight,
    previousPricePerKg,
    // 🆕 ADDED PROP
    hasUpdateForBuyer,
    hasUpdateForFisher,
    catchName,
    catchImageUrl,
    fisherName,
    fisherRating,
    fisherAvatarUrl,
    buyerName,
    buyerRating,
    buyerAvatarUrl,
  ];

  // Used for transactional updates (e.g., accepting or countering)
  Offer copyWith({
    OfferStatus? status,
    double? previousPrice,
    double? previousWeight,
    double? previousPricePerKg,
    double? price,
    double? weight,
    double? pricePerKg,
    String? dateCreated,
    bool? hasUpdateForFisher,
    bool? hasUpdateForBuyer,
    // Add parameters for denormalized fields if they can change
    String? catchName,
    String? catchImageUrl,
    String? fisherName,
    double? fisherRating,
    String? fisherAvatarUrl,
    String? buyerName,
    double? buyerRating,
    String? buyerAvatarUrl,
  }) {
    return Offer(
      id: id,
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      previousPrice: previousPrice ?? this.previousPrice,
      previousWeight: previousWeight ?? this.previousWeight,
      previousPricePerKg: previousPricePerKg ?? this.previousPricePerKg,
      // Update denormalized fields if provided, otherwise keep existing
      catchName: catchName ?? this.catchName,
      catchImageUrl: catchImageUrl ?? this.catchImageUrl,
      fisherName: fisherName ?? this.fisherName,
      fisherRating: fisherRating ?? this.fisherRating,
      fisherAvatarUrl: fisherAvatarUrl ?? this.fisherAvatarUrl,
      buyerName: buyerName ?? this.buyerName,
      buyerRating: buyerRating ?? this.buyerRating,
      buyerAvatarUrl: buyerAvatarUrl ?? this.buyerAvatarUrl,
      // 🆕 UPDATED COPYWITH LOGIC
      hasUpdateForBuyer: hasUpdateForBuyer ?? this.hasUpdateForBuyer,
      hasUpdateForFisher: hasUpdateForFisher ?? this.hasUpdateForFisher,
    );
  }

  // ------------------------------------
  // --- DB Mapping (Requires Back-End/Repository Update) ---
  // ------------------------------------

  Map<String, dynamic> toMap() => {
    'offer_id': id,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'price_per_kg': pricePerKg,
    'price': price,
    'weight': weight,
    'status': offerStatusToString(status),
    'date_created': dateCreated,
    'previous_price': previousPrice,
    'previous_weight': previousWeight,
    'previous_price_per_kg': previousPricePerKg,
    // 🆕 ADDED FIELD TO MAP
    'has_update_buyer': hasUpdateForBuyer ? 1 : 0,
    'has_update_fisher': hasUpdateForFisher ? 1 : 0,
    // Store as integer (0 or 1) for SQLite boolean

    // Include new fields in map for storage/transfer
    'catch_name': catchName,
    'catch_image_url': catchImageUrl,
    'fisher_name': fisherName,
    'fisher_rating': fisherRating,
    'fisher_avatar_url': fisherAvatarUrl,
    'buyer_name': buyerName,
    'buyer_rating': buyerRating,
    'buyer_avatar_url': buyerAvatarUrl,
  };

  factory Offer.fromMap(Map<String, dynamic> m) => Offer(
    id: m['offer_id'] as String,
    catchId: m['catch_id'] as String,
    fisherId: m['fisher_id'] as String,
    buyerId: m['buyer_id'] as String,
    pricePerKg: (m['price_per_kg'] as num).toDouble(),
    price: (m['price'] as num).toDouble(),
    weight: (m['weight'] as num).toDouble(),
    status: offerStatusFromString(m['status'] as String),
    dateCreated: m['date_created'] as String,
    previousPrice: (m['previous_price'] as num?)?.toDouble(),
    previousWeight: (m['previous_weight'] as num?)?.toDouble(),
    previousPricePerKg: (m['previous_price_per_kg'] as num?)?.toDouble(),
    // 🆕 EXTRACTED FIELD
    hasUpdateForBuyer: (m['has_update_buyer'] as int) == 1,
    hasUpdateForFisher: (m['has_update_fisher'] as int) == 1,
    // Extract new fields from the map, providing defaults if null
    catchName: m['catch_name'] as String? ?? '',
    catchImageUrl: m['catch_image_url'] as String? ?? '',
    fisherName: m['fisher_name'] as String? ?? '',
    fisherRating: (m['fisher_rating'] as num? ?? 0.0).toDouble(),
    fisherAvatarUrl: m['fisher_avatar_url'] as String? ?? '',
    buyerName: m['buyer_name'] as String? ?? '',
    buyerRating: (m['buyer_rating'] as num? ?? 0.0).toDouble(),
    buyerAvatarUrl: m['buyer_avatar_url'] as String? ?? '',
  );
}
