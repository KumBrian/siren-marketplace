import '../../domain/entities/offer.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/weight.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/rating.dart';

import '../models/offer_model.dart';

class OfferMapper {
  /// Convert domain entity to data model
  static OfferModel toModel(Offer entity) {
    return OfferModel(
      id: entity.id,
      productId: entity.productId,
      fisherId: entity.fisherId,
      buyerId: entity.buyerId,
      currentPriceAmount: entity.currentTerms.totalPrice.amount,
      currentWeightGrams: entity.currentTerms.weight.grams,
      currentPricePerKgAmount: entity.currentTerms.pricePerKg.amountPerKg,
      previousPriceAmount: entity.previousTerms?.totalPrice.amount,
      previousWeightGrams: entity.previousTerms?.weight.grams,
      previousPricePerKgAmount: entity.previousTerms?.pricePerKg.amountPerKg,
      status: entity.status.name,
      dateCreated: entity.dateCreated.toIso8601String(),
      dateUpdated: entity.dateUpdated.toIso8601String(),
      waitingFor: entity.waitingFor?.name,
      hasUpdateForFisher: entity.hasUpdateForFisher,
      hasUpdateForBuyer: entity.hasUpdateForBuyer,
      product: entity.product,
    );
  }

  /// Convert data model to domain entity
  static Offer toEntity(OfferModel model) {
    print('DEBUG OfferMapper.toEntity - model.buyer: ${model.buyer}');

    final currentWeight = Weight.fromGrams(model.currentWeightGrams);
    final currentPrice = Price.fromAmount(model.currentPriceAmount);
    final currentPpk = PricePerKg.fromAmount(model.currentPricePerKgAmount);

    final currentTerms = currentWeight.isZero
        ? OfferTerms.fromPricePerKg(
            pricePerKg: currentPpk,
            weight: currentWeight,
          )
        : OfferTerms.create(totalPrice: currentPrice, weight: currentWeight);

    OfferTerms? previousTerms;
    if (model.previousPriceAmount != null &&
        model.previousWeightGrams != null) {
      final prevWeight = Weight.fromGrams(model.previousWeightGrams!);
      final prevPrice = Price.fromAmount(model.previousPriceAmount!);
      final prevPpk = PricePerKg.fromAmount(
        model.previousPricePerKgAmount ?? 0,
      );

      previousTerms = prevWeight.isZero
          ? OfferTerms.fromPricePerKg(pricePerKg: prevPpk, weight: prevWeight)
          : OfferTerms.create(totalPrice: prevPrice, weight: prevWeight);
    }

    final mappedUserInfo = _mapUsers(model);

    final offer = Offer(
      id: model.id,
      productId: model.productId,
      fisherId: model.fisherId,
      buyerId: model.buyerId,
      currentTerms: currentTerms,
      previousTerms: previousTerms,
      status: _parseStatus(model.status),
      dateCreated: DateTime.parse(model.dateCreated),
      dateUpdated: DateTime.parse(model.dateUpdated),
      waitingFor: model.waitingFor != null
          ? _parseRole(model.waitingFor!)
          : null,
      hasUpdateForFisher: model.hasUpdateForFisher,
      hasUpdateForBuyer: model.hasUpdateForBuyer,
      product: model.product,
      fisher: mappedUserInfo['fisher'],
      buyer: mappedUserInfo['buyer'],
      orderId: model.orderUid,
    );

    return offer;
  }

  static Map<String, User?> _mapUsers(OfferModel model) {
    // Map Buyer
    User? buyer;
    if (model.buyer != null) {
      buyer = _mapAccountToUser(model.buyer!, UserRole.buyer);
    }

    // Map Fisher
    User? fisher;
    // Prefer direct fisher object, fallback to product's fisher
    if (model.fisher != null) {
      fisher = _mapAccountToUser(model.fisher!, UserRole.fisher);
    } else if (model.product?.fisher != null) {
      fisher = model.product!.fisher;
    }

    return {'buyer': buyer, 'fisher': fisher};
  }

  static User _mapAccountToUser(dynamic account, UserRole role) {
    // Helper to handle AccountApiModel or similar structure
    // Since we know it is AccountApiModel in OfferModel:
    // (Assuming AccountApiModel import is available, or we use dynamic and access properties)

    // Actually OfferModel uses AccountApiModel.
    return User(
      id: account.id.toString(),
      name:
          '${account.firstName ?? ''} ${account.lastName ?? ''}'.trim().isEmpty
          ? (account.username ?? 'Unknown')
          : '${account.firstName ?? ''} ${account.lastName ?? ''}'.trim(),
      rating: Rating.fromValue(account.rating ?? 0.0),
      reviewCount: account.totalReviews ?? 0,
      avatarUrl: account.avatar,
      currentRole: role,
    );
  }

  static OfferStatus _parseStatus(String status) {
    return OfferStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => OfferStatus.pending,
    );
  }

  static UserRole _parseRole(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.buyer,
    );
  }
}
