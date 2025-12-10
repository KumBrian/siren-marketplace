import '../api/models/offer_api_models.dart';
import '../models/offer_model.dart';
// import '../../domain/enums/offer_status.dart';

class OfferApiMapper {
  static OfferModel toDomain(OfferApiModel apiModel) {
    return OfferModel(
      id: apiModel.id.toString(),
      catchId:
          apiModel.catchId?.toString() ??
          apiModel.catchDetails?.id?.toString() ??
          'unknown_catch',
      fisherId:
          apiModel.fisherId?.toString() ??
          apiModel.fisher?.id?.toString() ??
          'unknown_fisher',
      buyerId:
          apiModel.buyerId?.toString() ??
          apiModel.buyer?.id?.toString() ??
          'unknown_buyer',
      currentPriceAmount: apiModel.currentPriceAmount ?? 0,
      currentWeightGrams: apiModel.currentWeightGrams ?? 0,
      currentPricePerKgAmount: apiModel.currentPricePerKgAmount ?? 0,
      previousPriceAmount: apiModel.previousPriceAmount,
      previousWeightGrams: apiModel.previousWeightGrams,
      previousPricePerKgAmount: apiModel.previousPricePerKgAmount,
      status: apiModel.status ?? 'pending',
      dateCreated: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      dateUpdated: apiModel.updatedAt ?? DateTime.now().toIso8601String(),
      waitingFor: 'fisher', // Default or derived from status logic
      hasUpdateForFisher: true,
      hasUpdateForBuyer: true,
    );
  }

  static CreateOfferRequest toRequest(OfferModel model) {
    return CreateOfferRequest(
      catchId: model.catchId,
      priceAmount: model.currentPriceAmount,
      weightGrams: model.currentWeightGrams,
      pricePerKgAmount: model.currentPricePerKgAmount,
    );
  }
}
