import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/weight.dart';
import '../models/order_model.dart';

class OrderMapper {
  /// Convert domain entity to data model
  static OrderModel toModel(Order entity) {
    return OrderModel(
      id: entity.id,
      offerId: entity.offerId,
      catchId: entity.catchId,
      fisherId: entity.fisherId,
      buyerId: entity.buyerId,
      termsPrice: entity.terms.totalPrice.amount,
      termsWeight: entity.terms.weight.grams,
      termsPricePerKg: entity.terms.pricePerKg.amountPerKg,
      status: entity.status.name,
      dateCreated: entity.dateCreated.toIso8601String(),
      dateUpdated: entity.dateUpdated.toIso8601String(),
      hasReviewFromFisher: entity.hasReviewFromFisher,
      hasReviewFromBuyer: entity.hasReviewFromBuyer,
    );
  }

  /// Convert data model to domain entity
  static Order toEntity(OrderModel model) {
    final terms = OfferTerms.create(
      totalPrice: Price.fromAmount(model.termsPrice),
      weight: Weight.fromGrams(model.termsWeight),
    );

    return Order(
      id: model.id,
      offerId: model.offerId,
      catchId: model.catchId,
      fisherId: model.fisherId,
      buyerId: model.buyerId,
      terms: terms,
      status: _parseStatus(model.status),
      dateCreated: DateTime.parse(model.dateCreated),
      dateUpdated: DateTime.parse(model.dateUpdated),
      hasReviewFromFisher: model.hasReviewFromFisher,
      hasReviewFromBuyer: model.hasReviewFromBuyer,
    );
  }

  static OrderStatus _parseStatus(String status) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => OrderStatus.active,
    );
  }
}
