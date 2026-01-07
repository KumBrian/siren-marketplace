import 'dart:convert';
import 'product_model.dart';
import 'user_model.dart';

class OrderModel {
  final String id;
  final String? orderNumber;
  final String? offerId; // Make nullable
  final String catchId;
  final String fisherId;
  final String buyerId;
  final int termsPrice;
  final int termsWeight;
  final int termsPricePerKg;
  final String status;
  final String dateCreated;
  final String dateUpdated;
  final bool hasReviewFromFisher;
  final bool hasReviewFromBuyer;
  final String? fisherReview; // JSON string
  final String? buyerReview; // JSON string
  final String? cancellationReason;
  // Embedded
  final ProductModel? product;
  final UserModel? buyer;

  const OrderModel({
    required this.id,
    this.orderNumber,
    this.offerId,
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
    this.fisherReview,
    this.buyerReview,
    this.cancellationReason,
    this.product,
    this.buyer,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
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
    'fisher_review': fisherReview,
    'buyer_review': buyerReview,
    'cancellation_reason': cancellationReason,
    // Note: API might not expect these in toJson if this is used for sending,
    // but usually models are for local/transport reading.
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    orderNumber: json['order_number'] as String?,
    offerId: json['offer_id'] as String?,
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
    fisherReview: json['fisher_review'] as String?,
    buyerReview: json['buyer_review'] as String?,
    cancellationReason: json['cancellation_reason'] as String?,
  );

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? offerId,
    String? catchId,
    String? fisherId,
    String? buyerId,
    int? termsPrice,
    int? termsWeight,
    int? termsPricePerKg,
    String? status,
    String? dateCreated,
    String? dateUpdated,
    bool? hasReviewFromFisher,
    bool? hasReviewFromBuyer,
    String? fisherReview,
    String? buyerReview,
    String? cancellationReason,
    ProductModel? product,
    UserModel? buyer,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      offerId: offerId ?? this.offerId,
      catchId: catchId ?? this.catchId,
      fisherId: fisherId ?? this.fisherId,
      buyerId: buyerId ?? this.buyerId,
      termsPrice: termsPrice ?? this.termsPrice,
      termsWeight: termsWeight ?? this.termsWeight,
      termsPricePerKg: termsPricePerKg ?? this.termsPricePerKg,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      hasReviewFromFisher: hasReviewFromFisher ?? this.hasReviewFromFisher,
      hasReviewFromBuyer: hasReviewFromBuyer ?? this.hasReviewFromBuyer,
      fisherReview: fisherReview ?? this.fisherReview,
      buyerReview: buyerReview ?? this.buyerReview,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      product: product ?? this.product,
      buyer: buyer ?? this.buyer,
    );
  }

  // SQLite mapping
  Map<String, dynamic> toMap() {
    return {
      'order_id': id,
      'order_number': orderNumber,
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
      'fisher_review': fisherReview,
      'buyer_review': buyerReview,
      'cancellation_reason': cancellationReason,
      'product_json': product != null ? jsonEncode(product!.toMap()) : null,
      'buyer_json': buyer != null ? jsonEncode(buyer!.toMap()) : null,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    ProductModel? product;
    if (map['product_json'] != null) {
      try {
        product = ProductModel.fromMap(jsonDecode(map['product_json']));
      } catch (e) {
        print('Error decoding product_json in OrderModel: $e');
      }
    }

    UserModel? buyer;
    if (map['buyer_json'] != null) {
      try {
        buyer = UserModel.fromMap(jsonDecode(map['buyer_json']));
      } catch (e) {
        print('Error decoding buyer_json in OrderModel: $e');
      }
    }

    return OrderModel(
      id: map['order_id'] as String,
      orderNumber: map['order_number'] as String?,
      offerId: map['offer_id'] as String?,
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
      fisherReview: map['fisher_review'] as String?,
      buyerReview: map['buyer_review'] as String?,
      cancellationReason: map['cancellation_reason'] as String?,
      product: product,
      buyer: buyer,
    );
  }
}
