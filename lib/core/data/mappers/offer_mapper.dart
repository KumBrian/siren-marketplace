import '../../domain/entities/offer.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/weight.dart';
import '../models/offer_model.dart';

class OfferMapper {
  /// Convert domain entity to data model
  static OfferModel toModel(Offer entity) {
    return OfferModel(
      id: entity.id,
      catchId: entity.catchId,
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
    );
  }

  /// Convert data model to domain entity
  static Offer toEntity(OfferModel model) {
    final currentTerms = OfferTerms.create(
      totalPrice: Price.fromAmount(model.currentPriceAmount),
      weight: Weight.fromGrams(model.currentWeightGrams),
    );

    OfferTerms? previousTerms;
    if (model.previousPriceAmount != null &&
        model.previousWeightGrams != null) {
      previousTerms = OfferTerms.create(
        totalPrice: Price.fromAmount(model.previousPriceAmount!),
        weight: Weight.fromGrams(model.previousWeightGrams!),
      );
    }

    return Offer(
      id: model.id,
      catchId: model.catchId,
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
