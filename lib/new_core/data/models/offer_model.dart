class OfferModel {
  final String id;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final int currentPriceAmount;
  final int currentWeightGrams;
  final int currentPricePerKgAmount;
  final int? previousPriceAmount;
  final int? previousWeightGrams;
  final int? previousPricePerKgAmount;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final String dateCreated; // ISO8601
  final String dateUpdated; // ISO8601
  final String? waitingFor; // 'fisher' or 'buyer'

  const OfferModel({
    required this.id,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.currentPriceAmount,
    required this.currentWeightGrams,
    required this.currentPricePerKgAmount,
    this.previousPriceAmount,
    this.previousWeightGrams,
    this.previousPricePerKgAmount,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.waitingFor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'current_price_amount': currentPriceAmount,
    'current_weight_grams': currentWeightGrams,
    'current_price_per_kg_amount': currentPricePerKgAmount,
    'previous_price_amount': previousPriceAmount,
    'previous_weight_grams': previousWeightGrams,
    'previous_price_per_kg_amount': previousPricePerKgAmount,
    'status': status,
    'date_created': dateCreated,
    'date_updated': dateUpdated,
    'waiting_for': waitingFor,
  };

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
    id: json['id'] as String,
    catchId: json['catch_id'] as String,
    fisherId: json['fisher_id'] as String,
    buyerId: json['buyer_id'] as String,
    currentPriceAmount: (json['current_price_amount'] as num).toInt(),
    currentWeightGrams: (json['current_weight_grams'] as num).toInt(),
    currentPricePerKgAmount: (json['current_price_per_kg_amount'] as num)
        .toInt(),
    previousPriceAmount: (json['previous_price_amount'] as num?)?.toInt(),
    previousWeightGrams: (json['previous_weight_grams'] as num?)?.toInt(),
    previousPricePerKgAmount: (json['previous_price_per_kg_amount'] as num?)
        ?.toInt(),
    status: json['status'] as String,
    dateCreated: json['date_created'] as String,
    dateUpdated: json['date_updated'] as String,
    waitingFor: json['waiting_for'] as String?,
  );

  // SQLite mapping
  Map<String, dynamic> toMap() => {
    'offer_id': id,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'price': currentPriceAmount,
    'weight': currentWeightGrams,
    'price_per_kg': currentPricePerKgAmount,
    'previous_price': previousPriceAmount,
    'previous_weight': previousWeightGrams,
    'previous_price_per_kg': previousPricePerKgAmount,
    'status': status,
    'date_created': dateCreated,
    'date_updated': dateUpdated,
    'waiting_for': waitingFor,
  };

  factory OfferModel.fromMap(Map<String, dynamic> map) => OfferModel(
    id: map['offer_id'] as String,
    catchId: map['catch_id'] as String,
    fisherId: map['fisher_id'] as String,
    buyerId: map['buyer_id'] as String,
    currentPriceAmount: (map['price'] as num).toInt(),
    currentWeightGrams: (map['weight'] as num).toInt(),
    currentPricePerKgAmount: (map['price_per_kg'] as num).toInt(),
    previousPriceAmount: (map['previous_price'] as num?)?.toInt(),
    previousWeightGrams: (map['previous_weight'] as num?)?.toInt(),
    previousPricePerKgAmount: (map['previous_price_per_kg'] as num?)?.toInt(),
    status: map['status'] as String,
    dateCreated: map['date_created'] as String,
    dateUpdated: map['date_updated'] as String,
    waitingFor: map['waiting_for'] as String?,
  );
}
