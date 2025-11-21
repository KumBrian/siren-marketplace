class OrderModel {
  final String id;
  final String offerId;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final int termsPrice;
  final int termsWeight;
  final int termsPricePerKg;
  final String status; // 'active', 'completed', 'cancelled'
  final String dateCreated; // ISO8601
  final String dateUpdated; // ISO8601
  final bool hasReviewFromFisher;
  final bool hasReviewFromBuyer;

  const OrderModel({
    required this.id,
    required this.offerId,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.termsPrice,
    required this.termsWeight,
    required this.termsPricePerKg,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    required this.hasReviewFromFisher,
    required this.hasReviewFromBuyer,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offer_id': offerId,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'terms_price': termsPrice,
    'terms_weight': termsWeight,
    'terms_price_per_kg': termsPricePerKg,
    'status': status,
    'date_created': dateCreated,
    'date_updated': dateUpdated,
    'has_review_from_fisher': hasReviewFromFisher,
    'has_review_from_buyer': hasReviewFromBuyer,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    offerId: json['offer_id'] as String,
    catchId: json['catch_id'] as String,
    fisherId: json['fisher_id'] as String,
    buyerId: json['buyer_id'] as String,
    termsPrice: (json['terms_price'] as num).toInt(),
    termsWeight: (json['terms_weight'] as num).toInt(),
    termsPricePerKg: (json['terms_price_per_kg'] as num).toInt(),
    status: json['status'] as String,
    dateCreated: json['date_created'] as String,
    dateUpdated: json['date_updated'] as String,
    hasReviewFromFisher: json['has_review_from_fisher'] as bool? ?? false,
    hasReviewFromBuyer: json['has_review_from_buyer'] as bool? ?? false,
  );

  // SQLite mapping
  Map<String, dynamic> toMap() => {
    'order_id': id,
    'offer_id': offerId,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'terms_price': termsPrice,
    'terms_weight': termsWeight,
    'terms_price_per_kg': termsPricePerKg,
    'status': status,
    'date_created': dateCreated,
    'date_updated': dateUpdated,
    'has_review_from_fisher': hasReviewFromFisher ? 1 : 0,
    'has_review_from_buyer': hasReviewFromBuyer ? 1 : 0,
  };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['order_id'] as String,
    offerId: map['offer_id'] as String,
    catchId: map['catch_id'] as String,
    fisherId: map['fisher_id'] as String,
    buyerId: map['buyer_id'] as String,
    termsPrice: (map['terms_price'] as num).toInt(),
    termsWeight: (map['terms_weight'] as num).toInt(),
    termsPricePerKg: (map['terms_price_per_kg'] as num).toInt(),
    status: map['status'] as String,
    dateCreated: map['date_created'] as String,
    dateUpdated: map['date_updated'] as String,
    hasReviewFromFisher: (map['has_review_from_fisher'] as int?) == 1,
    hasReviewFromBuyer: (map['has_review_from_buyer'] as int?) == 1,
  );
}
