import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../api/models/order_api_models.dart';
import 'product_mapper.dart';
import 'user_mapper.dart';

class OrderMapper {
  /// Convert API model directly to domain entity (for embedded data)
  static Order fromApi(OrderApiModel apiModel) {
    // Map offer terms from the terms_* fields
    // Handle zero weight case to avoid division by zero
    final totalPrice = Price.fromAmount(apiModel.termsPrice ?? 0);
    final weight = Weight.fromGrams(apiModel.termsWeight ?? 0);
    final pricePerKg = PricePerKg.fromAmount(apiModel.termsPricePerKg ?? 0);

    final terms = weight.isZero
        ? OfferTerms.fromPricePerKg(pricePerKg: pricePerKg, weight: weight)
        : OfferTerms.create(totalPrice: totalPrice, weight: weight);

    // Map embedded product if available
    final product = apiModel.product != null
        ? ProductMapper.toDomain(apiModel.product!)
        : null;

    // Map embedded buyer if available (from dynamic JSON)
    final buyer = apiModel.buyer != null && apiModel.buyer is Map
        ? UserMapper.toEntity(
            UserModel.fromJson(apiModel.buyer as Map<String, dynamic>),
          )
        : null;

    // Extract IDs - fisher from embedded product, buyer from embedded buyer
    final String fisherId = product?.fisherId ?? '';
    final String catchId = product?.id ?? '';
    final String buyerId = buyer?.id ?? '';

    return Order(
      id: apiModel.id.toString(),
      offerId: '', // Not in response currently
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      terms: terms,
      status: _parseStatus(apiModel.status ?? 'pending'),
      orderNumber: apiModel.orderNumber,
      product: product,
      buyer: buyer,
      dateCreated: apiModel.createdAt != null
          ? DateTime.tryParse(apiModel.createdAt!) ?? DateTime.now()
          : DateTime.now(),
      dateUpdated: apiModel.updatedAt != null
          ? DateTime.tryParse(apiModel.updatedAt!) ?? DateTime.now()
          : DateTime.now(),
      hasReviewFromFisher: apiModel.fisherReview != null,
      hasReviewFromBuyer: apiModel.buyerReview != null,
      cancellationReason: apiModel.cancellationReason,
    );
  }

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
      cancellationReason: entity.cancellationReason,
    );
  }

  /// Convert data model to domain entity
  static Order toEntity(OrderModel model) {
    // Handle zero weight case
    final totalPrice = Price.fromAmount(model.termsPrice);
    final weight = Weight.fromGrams(model.termsWeight);
    final pricePerKg = PricePerKg.fromAmount(model.termsPricePerKg);

    final terms = weight.isZero
        ? OfferTerms.fromPricePerKg(pricePerKg: pricePerKg, weight: weight)
        : OfferTerms.create(totalPrice: totalPrice, weight: weight);

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
      cancellationReason: model.cancellationReason,
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'accepted':
        return OrderStatus.accepted;
      case 'delivered':
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.accepted;
    }
  }
}
