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
  final String? previousOfferId;

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
    required this.id,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.pricePerKg,
    required this.price,
    required this.weight,
    required this.status,
    required this.dateCreated,
    required this.buyerName,
    required this.buyerRating,
    required this.buyerAvatarUrl,
    this.previousOfferId,
    required this.catchName,
    required this.catchImageUrl,
    required this.fisherName,
    required this.fisherRating,
    required this.fisherAvatarUrl,
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
    previousOfferId,
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
  Offer copyWith({OfferStatus? status, String? previousOfferId}) {
    return Offer(
      id: id,
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      pricePerKg: pricePerKg,
      price: price,
      weight: weight,
      status: status ?? this.status,
      dateCreated: dateCreated,
      previousOfferId: previousOfferId ?? this.previousOfferId,

      // Crucially, include all denormalized fields in copyWith
      catchName: catchName,
      catchImageUrl: catchImageUrl,
      fisherName: fisherName,
      fisherRating: fisherRating,
      fisherAvatarUrl: fisherAvatarUrl,
      buyerName: buyerName,
      buyerRating: buyerRating,
      buyerAvatarUrl: buyerAvatarUrl,
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
    'previous_counter_offer': previousOfferId,

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
    previousOfferId: m['previous_counter_offer'] as String?,

    // Extract new fields from the map
    catchName: m['catch_name'] as String,
    catchImageUrl: m['catch_image_url'] as String,
    fisherName: m['fisher_name'] as String,
    fisherRating: (m['fisher_rating'] as num).toDouble(),
    fisherAvatarUrl: m['fisher_avatar_url'] as String,
    buyerName: m['buyer_name'] as String,
    buyerRating: (m['buyer_rating'] as num).toDouble(),
    buyerAvatarUrl: m['buyer_avatar_url'] as String,
  );
}
