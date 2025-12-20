import '../api/models/offer_api_models.dart';
import '../models/offer_model.dart';
import '../mappers/product_mapper.dart';
// import '../../domain/enums/offer_status.dart';

class OfferApiMapper {
  static OfferModel toDomain(OfferApiModel apiModel) {
    return OfferModel(
      id: apiModel.id.toString(),
      productId: apiModel.product?.id?.toString() ?? 'unknown_catch',
      fisherId: apiModel.product?.account?.uid ?? 'unknown_fisher',
      buyerId: apiModel.buyer?.id.toString() ?? 'unknown_buyer',
      currentPriceAmount: apiModel.currentPriceAmount ?? 0,
      currentWeightGrams: apiModel.currentWeightGrams ?? 0,
      currentPricePerKgAmount: apiModel.currentPricePerKgAmount ?? 0,
      previousPriceAmount: apiModel.previousPriceAmount,
      previousWeightGrams: apiModel.previousWeightGrams,
      previousPricePerKgAmount: apiModel.previousPricePerKgAmount,
      status: apiModel.status ?? 'pending',
      dateCreated: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      dateUpdated: apiModel.updatedAt ?? DateTime.now().toIso8601String(),
      waitingFor: apiModel.waitingFor ?? 'fisher',
      hasUpdateForFisher: apiModel.hasUpdateForFisher ?? true,
      hasUpdateForBuyer: apiModel.hasUpdateForBuyer ?? true,
      product: apiModel.product != null
          ? ProductMapper.toDomain(apiModel.product!)
          : null,
    );
  }

  static CreateOfferRequest toRequest(OfferModel model) {
    dynamic productId = model.productId;
    // Try to parse to int if it looks like an int, because backend examples show int product ID
    if (int.tryParse(model.productId) != null) {
      productId = int.parse(model.productId);
    }

    return CreateOfferRequest(
      product: productId, // catchId is the product ID
      price: model.currentPriceAmount.toDouble(),
      weightInGrams: model.currentWeightGrams.toDouble(),
      pricePerKg: model.currentPricePerKgAmount.toDouble(),
    );
  }
}
