import 'package:siren_marketplace/core/domain/models/order.dart';

class OrderEntity {
  final String id;
  final String offerId;
  final String fisherId;
  final String buyerId;
  final String catchSnapshotJson;
  final String dateUpdated;
  final bool hasRatedBuyer;
  final bool hasRatedFisher;
  final double? buyerRatingValue;
  final String? buyerRatingMessage;
  final double? fisherRatingValue;
  final String? fisherRatingMessage;

  OrderEntity({
    required this.id,
    required this.offerId,
    required this.fisherId,
    required this.buyerId,
    required this.catchSnapshotJson,
    required this.dateUpdated,
    this.hasRatedBuyer = false,
    this.hasRatedFisher = false,
    this.buyerRatingValue,
    this.buyerRatingMessage,
    this.fisherRatingValue,
    this.fisherRatingMessage,
  });

  factory OrderEntity.fromMap(Map<String, dynamic> m) {
    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return OrderEntity(
      id: m['order_id'] as String,
      offerId: m['offer_id'] as String,
      fisherId: m['fisher_id'] as String,
      buyerId: m['buyer_id'] as String,
      catchSnapshotJson: m['catch_snapshot'] as String,
      dateUpdated: m['date_updated'] as String,
      hasRatedBuyer: (m['hasRatedBuyer'] as int?) == 1,
      hasRatedFisher: (m['hasRatedFisher'] as int?) == 1,
      buyerRatingValue: safeParseDouble(m['buyer_rating_value']),
      buyerRatingMessage: m['buyer_rating_message'] as String?,
      fisherRatingValue: safeParseDouble(m['fisher_rating_value']),
      fisherRatingMessage: m['fisher_rating_message'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'order_id': id,
    'offer_id': offerId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'catch_snapshot': catchSnapshotJson,
    'date_updated': dateUpdated,
    'hasRatedBuyer': hasRatedBuyer ? 1 : 0,
    'hasRatedFisher': hasRatedFisher ? 1 : 0,
    'buyer_rating_value': buyerRatingValue,
    'buyer_rating_message': buyerRatingMessage,
    'fisher_rating_value': fisherRatingValue,
    'fisher_rating_message': fisherRatingMessage,
  };

  // Note: toDomain and fromDomain will require linked objects (Offer, Catch) from the repository
  // These methods here will be simplified as they are only dealing with the persistence layer.
  // The full domain object reconstruction happens in the repository.

  static OrderEntity fromDomain(Order order) {
    return OrderEntity(
      id: order.id,
      offerId: order.offer.id,
      fisherId: order.fisherId,
      buyerId: order.buyerId,
      catchSnapshotJson: order.catchSnapshotJson,
      dateUpdated: order.dateUpdated,
      hasRatedBuyer: order.hasRatedBuyer,
      hasRatedFisher: order.hasRatedFisher,
      buyerRatingValue: order.buyerRatingValue,
      buyerRatingMessage: order.buyerRatingMessage,
      fisherRatingValue: order.fisherRatingValue,
      fisherRatingMessage: order.fisherRatingMessage,
    );
  }
}
