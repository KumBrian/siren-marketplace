import 'package:siren_marketplace/core/types/enum.dart';

class Offer {
  final String id;
  final String catchId;
  final String fisherId;
  final String fisherName;
  final double fisherRating;
  final String fisherAvatarUrl;
  final String buyerId;
  final String buyerName;
  final double buyerRating;
  final String buyerAvatarUrl;
  final String catchName;
  final String catchImageUrl;
  final double price;
  final double weight;
  final double pricePerKg;
  final OfferStatus status;
  final bool hasUpdateForBuyer;
  final bool hasUpdateForFisher;
  final String dateCreated; // ISO string to match your DB
  final Role? waitingFor;

  final double? previousPrice;
  final double? previousWeight;
  final double? previousPricePerKg;

  Offer({
    required this.id,
    required this.catchId,
    required this.fisherId,
    required this.fisherName,
    required this.fisherRating,
    required this.fisherAvatarUrl,
    required this.buyerId,
    required this.buyerName,
    required this.buyerRating,
    required this.buyerAvatarUrl,
    required this.catchName,
    required this.catchImageUrl,
    required this.price,
    required this.weight,
    required this.pricePerKg,
    required this.status,
    required this.hasUpdateForBuyer,
    required this.hasUpdateForFisher,
    required this.dateCreated,
    required this.waitingFor,
    this.previousPrice,
    this.previousWeight,
    this.previousPricePerKg,
  });

  Offer copyWith({
    String? id,
    String? catchId,
    String? fisherId,
    String? fisherName,
    double? fisherRating,
    String? fisherAvatarUrl,
    String? buyerId,
    String? buyerName,
    double? buyerRating,
    String? buyerAvatarUrl,
    String? catchName,
    String? catchImageUrl,
    double? price,
    double? weight,
    double? pricePerKg,
    OfferStatus? status,
    bool? hasUpdateForBuyer,
    bool? hasUpdateForFisher,
    String? dateCreated,
    Role? waitingFor,
    double? previousPrice,
    double? previousWeight,
    double? previousPricePerKg,
  }) {
    return Offer(
      id: id ?? this.id,
      catchId: catchId ?? this.catchId,
      fisherId: fisherId ?? this.fisherId,
      fisherName: fisherName ?? this.fisherName,
      fisherRating: fisherRating ?? this.fisherRating,
      fisherAvatarUrl: fisherAvatarUrl ?? this.fisherAvatarUrl,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerRating: buyerRating ?? this.buyerRating,
      buyerAvatarUrl: buyerAvatarUrl ?? this.buyerAvatarUrl,
      catchName: catchName ?? this.catchName,
      catchImageUrl: catchImageUrl ?? this.catchImageUrl,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      status: status ?? this.status,
      hasUpdateForBuyer: hasUpdateForBuyer ?? this.hasUpdateForBuyer,
      hasUpdateForFisher: hasUpdateForFisher ?? this.hasUpdateForFisher,
      dateCreated: dateCreated ?? this.dateCreated,
      waitingFor: waitingFor ?? this.waitingFor,
      previousPrice: previousPrice ?? this.previousPrice,
      previousWeight: previousWeight ?? this.previousWeight,
      previousPricePerKg: previousPricePerKg ?? this.previousPricePerKg,
    );
  }

  // convenience: convert to a DB-friendly map (column names matching current DB)
  Map<String, dynamic> toMap() {
    return {
      'offer_id': id,
      'catch_id': catchId,
      'fisher_id': fisherId,
      'fisher_name': fisherName,
      'fisher_rating': fisherRating,
      'fisher_avatar': fisherAvatarUrl,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'buyer_rating': buyerRating,
      'buyer_avatar': buyerAvatarUrl,
      'catch_name': catchName,
      'catch_image_url': catchImageUrl,
      'price': price,
      'weight': weight,
      'price_per_kg': pricePerKg,
      'status': status.name,
      'has_update_for_buyer': hasUpdateForBuyer ? 1 : 0,
      'has_update_for_fisher': hasUpdateForFisher ? 1 : 0,
      'date_created': dateCreated,
      'waiting_for': waitingFor?.name,
      'previous_price': previousPrice,
      'previous_weight': previousWeight,
      'previous_price_per_kg': previousPricePerKg,
    };
  }

  static Offer fromMap(Map<String, dynamic> m) {
    return Offer(
      id: (m['offer_id'] ?? m['id']) as String,
      catchId: m['catch_id'] as String,
      fisherId: m['fisher_id'] as String,
      fisherName: m['fisher_name'] as String? ?? '',
      fisherRating: (m['fisher_rating'] as num?)?.toDouble() ?? 0.0,
      fisherAvatarUrl: m['fisher_avatar'] as String? ?? '',
      buyerId: m['buyer_id'] as String? ?? '',
      buyerName: m['buyer_name'] as String? ?? '',
      buyerRating: (m['buyer_rating'] as num?)?.toDouble() ?? 0.0,
      buyerAvatarUrl: m['buyer_avatar'] as String? ?? '',
      catchName: m['catch_name'] as String? ?? '',
      catchImageUrl: m['catch_image_url'] as String? ?? '',
      price: (m['price'] as num).toDouble(),
      weight: (m['weight'] as num).toDouble(),
      pricePerKg: (m['price_per_kg'] as num).toDouble(),
      status: OfferStatus.values.byName(m['status'] as String),
      hasUpdateForBuyer:
          (m['has_update_for_buyer'] == 1) ||
          (m['has_update_for_buyer'] == true),
      hasUpdateForFisher:
          (m['has_update_for_fisher'] == 1) ||
          (m['has_update_for_fisher'] == true),
      dateCreated: m['date_created'] as String,
      waitingFor: m['waiting_for'] != null
          ? Role.values.byName(m['waiting_for'] as String)
          : null,
      previousPrice: (m['previous_price'] as num?)?.toDouble(),
      previousWeight: (m['previous_weight'] as num?)?.toDouble(),
      previousPricePerKg: (m['previous_price_per_kg'] as num?)?.toDouble(),
    );
  }
}
