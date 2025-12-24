import '../../domain/entities/product.dart';
import '../api/models/product_api_models.dart';
import '../mappers/product_mapper.dart';
import '../api/models/auth_api_models.dart';

class OfferModel {
  final String id;
  final String productId;
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
  final bool hasUpdateForFisher;
  final bool hasUpdateForBuyer;
  final Product? product;
  final AccountApiModel? buyer;
  final String? orderUid; // UID of sale order when offer is accepted

  const OfferModel({
    required this.id,
    required this.productId,
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
    this.hasUpdateForFisher = true,
    this.hasUpdateForBuyer = true,
    this.product,
    this.buyer,
    this.orderUid,
  });

  OfferModel copyWith({
    String? id,
    String? productId,
    String? fisherId,
    String? buyerId,
    int? currentPriceAmount,
    int? currentWeightGrams,
    int? currentPricePerKgAmount,
    int? previousPriceAmount,
    int? previousWeightGrams,
    int? previousPricePerKgAmount,
    String? status,
    String? dateCreated,
    String? dateUpdated,
    String? waitingFor,
    bool? hasUpdateForFisher,
    bool? hasUpdateForBuyer,
    Product? product,
    AccountApiModel? buyer,
    String? orderUid,
  }) {
    return OfferModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      fisherId: fisherId ?? this.fisherId,
      buyerId: buyerId ?? this.buyerId,
      currentPriceAmount: currentPriceAmount ?? this.currentPriceAmount,
      currentWeightGrams: currentWeightGrams ?? this.currentWeightGrams,
      currentPricePerKgAmount:
          currentPricePerKgAmount ?? this.currentPricePerKgAmount,
      previousPriceAmount: previousPriceAmount ?? this.previousPriceAmount,
      previousWeightGrams: previousWeightGrams ?? this.previousWeightGrams,
      previousPricePerKgAmount:
          previousPricePerKgAmount ?? this.previousPricePerKgAmount,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      waitingFor: waitingFor ?? this.waitingFor,
      hasUpdateForFisher: hasUpdateForFisher ?? this.hasUpdateForFisher,
      hasUpdateForBuyer: hasUpdateForBuyer ?? this.hasUpdateForBuyer,
      product: product ?? this.product,
      buyer: buyer ?? this.buyer,
      orderUid: orderUid ?? this.orderUid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'catch_id': productId,
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
    'has_update_for_fisher': hasUpdateForFisher,
    'has_update_for_buyer': hasUpdateForBuyer,
  };

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get nested ID
    String? getNestedId(dynamic data) {
      if (data is Map) {
        return data['uid'] as String?;
      } else if (data is String) {
        return data; // If it's already an ID string
      }
      return null;
    }

    // Parse nested product if available
    Product? product;
    String productId = '';
    String fisherId = '';

    if (json['product'] != null && json['product'] is Map) {
      try {
        final productApi = ProductApiModel.fromJson(
          json['product'] as Map<String, dynamic>,
        );
        product = ProductMapper.toDomain(productApi);
        productId = product!.id;
        fisherId = product!.fisherId; // Use fisherId from product mapping
      } catch (e) {
        print('Error parsing nested product in OfferModel: $e');
      }
    }

    // Fallback for IDs if nested product parsing failed or fields are direct
    if (productId.isEmpty) {
      productId = json['catch_id'] as String? ?? '';
    }
    if (fisherId.isEmpty) {
      // Check 'account' object at root for id (integer) first, fallback to uid
      if (json['account'] != null && json['account'] is Map) {
        fisherId =
            (json['account']['id'] ?? json['account']['uid'])?.toString() ?? '';
      } else {
        fisherId = json['fisher_id']?.toString() ?? '';
        if (fisherId.isEmpty && json['fisher'] is Map) {
          fisherId =
              (json['fisher']['id'] ?? json['fisher']['uid'])?.toString() ?? '';
        }
      }
    }

    // For buyerId, use the integer 'id' field to match how currentUser.id is stored
    // NOT the 'uid' field
    String buyerId = '';
    if (json['buyer'] != null && json['buyer'] is Map) {
      buyerId = (json['buyer']['id'] ?? json['buyer']['uid'])?.toString() ?? '';
    } else if (json['buyer_id'] != null) {
      buyerId = json['buyer_id'].toString();
    }

    AccountApiModel? buyer;
    if (json['buyer'] != null && json['buyer'] is Map) {
      try {
        buyer = AccountApiModel.fromJson(json['buyer'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing nested buyer in OfferModel: $e');
      }
    }

    // Handle amounts (support both camelCase and snake_case)
    int getInt(String key1, String key2) {
      return (json[key1] as num?)?.toInt() ??
          (json[key2] as num?)?.toInt() ??
          0;
    }

    int? getNullableInt(String key1, String key2) {
      return (json[key1] as num?)?.toInt() ?? (json[key2] as num?)?.toInt();
    }

    return OfferModel(
      id: json['uid'] as String? ?? json['id']?.toString() ?? '',
      productId: productId,
      fisherId: fisherId,
      buyerId: buyerId,
      currentPriceAmount: getInt('currentPriceAmount', 'current_price_amount'),
      currentWeightGrams: getInt('currentWeightGrams', 'current_weight_grams'),
      currentPricePerKgAmount: getInt(
        'currentPricePerKgAmount',
        'current_price_per_kg_amount',
      ),
      previousPriceAmount: getNullableInt(
        'previousPriceAmount',
        'previous_price_amount',
      ),
      previousWeightGrams: getNullableInt(
        'previousWeightGrams',
        'previous_weight_grams',
      ),
      previousPricePerKgAmount: getNullableInt(
        'previousPricePerKgAmount',
        'previous_price_per_kg_amount',
      ),
      status: json['status'] as String? ?? 'pending',
      dateCreated:
          json['created_at'] as String? ??
          json['date_created'] as String? ??
          DateTime.now().toIso8601String(),
      dateUpdated:
          json['updated_at'] as String? ??
          json['date_updated'] as String? ??
          DateTime.now().toIso8601String(),
      waitingFor: json['waiting_for'] as String?,
      hasUpdateForFisher:
          (json['has_update_for_fisher'] as bool?) ??
          (json['hasUpdateForFisher'] as bool?) ??
          true,
      hasUpdateForBuyer:
          (json['has_update_for_buyer'] as bool?) ??
          (json['hasUpdateForBuyer'] as bool?) ??
          true,
      product: product,
      buyer: buyer,
    );
  }

  // SQLite mapping
  Map<String, dynamic> toMap() => {
    'offer_id': id,
    'catch_id': productId,
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
    'has_update_for_fisher': hasUpdateForFisher ? 1 : 0,
    'has_update_for_buyer': hasUpdateForBuyer ? 1 : 0,
  };

  factory OfferModel.fromMap(Map<String, dynamic> map) => OfferModel(
    id: map['offer_id'] as String,
    productId: map['catch_id'] as String,
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
    hasUpdateForFisher: ((map['has_update_for_fisher'] as int?) ?? 1) == 1,
    hasUpdateForBuyer: ((map['has_update_for_buyer'] as int?) ?? 1) == 1,
  );
}
