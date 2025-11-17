import 'package:siren_marketplace/core/domain/models/catch.dart';
import 'package:siren_marketplace/core/domain/models/offer.dart';
import 'package:siren_marketplace/core/domain/models/order.dart';

class OrderDto {
  final Map<String, dynamic> json;

  OrderDto(this.json);

  Order toDomain({required Offer linkedOffer, required Catch linkedCatch}) {
    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Order(
      id: json['order_id'] as String,
      offer: linkedOffer,
      fisherId: json['fisher_id'] as String,
      buyerId: json['buyer_id'] as String,
      catchSnapshotJson: json['catch_snapshot'] as String,
      dateUpdated: json['date_updated'] as String,
      catchModel: linkedCatch,
      hasRatedBuyer: (json['hasRatedBuyer'] as int?) == 1,
      hasRatedFisher: (json['hasRatedFisher'] as int?) == 1,
      buyerRatingValue: safeParseDouble(json['buyer_rating_value']),
      buyerRatingMessage: json['buyer_rating_message'] as String?,
      fisherRatingValue: safeParseDouble(json['fisher_rating_value']),
      fisherRatingMessage: json['fisher_rating_message'] as String?,
    );
  }

  static Map<String, dynamic> fromDomain(Order order) {
    return {
      'order_id': order.id,
      'offer_id': order.offer.id,
      'fisher_id': order.fisherId,
      'buyer_id': order.buyerId,
      'catch_snapshot': order.catchSnapshotJson,
      'date_updated': order.dateUpdated,
      'hasRatedBuyer': order.hasRatedBuyer ? 1 : 0,
      'hasRatedFisher': order.hasRatedFisher ? 1 : 0,
      'buyer_rating_value': order.buyerRatingValue,
      'buyer_rating_message': order.buyerRatingMessage,
      'fisher_rating_value': order.fisherRatingValue,
      'fisher_rating_message': order.fisherRatingMessage,
    };
  }
}
