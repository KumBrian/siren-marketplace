import 'package:siren_marketplace/core/data/models/order_model.dart';
import '../api/models/order_api_models.dart';

class OrderApiMapper {
  static OrderModel toDomain(OrderApiModel apiModel) {
    return OrderModel(
      id: apiModel.id.toString(),
      // Placeholders for fields missing in API response
      offerId: 'unknown_offer',
      catchId: 'unknown_catch',
      fisherId: 'unknown_fisher',
      buyerId: 'unknown_buyer',
      termsPrice: 0,
      termsWeight: 0,
      termsPricePerKg: 0,
      status: apiModel.status ?? 'pending',
      dateCreated: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      dateUpdated: apiModel.updatedAt ?? DateTime.now().toIso8601String(),
      hasReviewFromFisher: false,
      hasReviewFromBuyer:
          apiModel.hasReviewFromBuyer, // Assuming presence means review exists
      cancellationReason: apiModel.cancellationReason,
    );
  }

  // Request body creation (if needed)
  static Map<String, dynamic> toCreateBody(OrderModel order) {
    return {
      // TODO: Define create body when requirements are clear
      // For now simple placeholder or minimal fields
      'offer': order.offerId.isNotEmpty ? '/api/offers/${order.offerId}' : null,
    };
  }
}
