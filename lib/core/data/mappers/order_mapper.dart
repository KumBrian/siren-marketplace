import 'dart:convert';
import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../api/models/order_api_models.dart';
import 'product_mapper.dart';
import 'user_mapper.dart';
import 'review_mapper.dart';

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
      offerId: null, // Not in API response
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
      fisherReview: apiModel.fisherReview != null
          ? ReviewMapper.fromApi(apiModel.fisherReview!)
          : null,
      buyerReview: apiModel.buyerReview != null
          ? ReviewMapper.fromApi(apiModel.buyerReview!)
          : null,
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
      orderNumber: entity.orderNumber,
      dateCreated: entity.dateCreated.toIso8601String(),
      dateUpdated: entity.dateUpdated.toIso8601String(),
      hasReviewFromFisher: entity.hasReviewFromFisher,
      hasReviewFromBuyer: entity.hasReviewFromBuyer,
      fisherReview: entity.fisherReview != null
          ? jsonEncode(ReviewMapper.toModel(entity.fisherReview!).toJson())
          : null,
      buyerReview: entity.buyerReview != null
          ? jsonEncode(ReviewMapper.toModel(entity.buyerReview!).toJson())
          : null,
      cancellationReason: entity.cancellationReason,
      // Map embedded objects
      product: entity.product != null
          ? ProductModel.fromDomain(entity.product!)
          : null,
      buyer: entity.buyer != null ? UserMapper.toModel(entity.buyer!) : null,
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
      orderNumber: model.orderNumber,
      dateCreated: DateTime.parse(model.dateCreated),
      dateUpdated: DateTime.parse(model.dateUpdated),
      fisherReview: model.fisherReview != null && model.fisherReview!.isNotEmpty
          ? ReviewMapper.toEntity(
              ReviewModel.fromJson(jsonDecode(model.fisherReview!)),
            )
          : null,
      buyerReview: model.buyerReview != null && model.buyerReview!.isNotEmpty
          ? ReviewMapper.toEntity(
              ReviewModel.fromJson(jsonDecode(model.buyerReview!)),
            )
          : null,
      cancellationReason: model.cancellationReason,
      // Map embedded objects
      product: model.product?.toDomain(),
      buyer: model.buyer != null ? UserMapper.toEntity(model.buyer!) : null,
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
