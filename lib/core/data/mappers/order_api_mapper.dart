import 'package:siren_marketplace/core/data/models/product_model.dart';
import 'package:siren_marketplace/core/data/models/user_model.dart';
import '../../data/models/order_model.dart';
import '../api/models/order_api_models.dart';
import 'product_mapper.dart';

class OrderApiMapper {
  static OrderModel toDomain(OrderApiModel apiModel) {
    // Map embedded product
    ProductModel? productModel;
    if (apiModel.product != null) {
      try {
        final productEntity = ProductMapper.toDomain(apiModel.product!);
        productModel = ProductModel.fromDomain(productEntity);
      } catch (e) {
        print('Error mapping product in OrderApiMapper: $e');
      }
    }

    // Map embedded buyer
    UserModel? buyerModel;
    if (apiModel.buyer != null && apiModel.buyer is Map) {
      try {
        buyerModel = UserModel.fromJson(apiModel.buyer as Map<String, dynamic>);
      } catch (e) {
        print('Error mapping buyer in OrderApiMapper: $e');
      }
    }

    return OrderModel(
      id: apiModel.id.toString(),
      // Use embedded data for IDs if available, fallback to apiModel fields if any (apiModel doesn't have top level IDs usually)
      offerId:
          null, // API usually doesn't return offerId on order list directly?
      catchId: productModel?.id ?? 'unknown_catch',
      fisherId: productModel?.fisherId ?? 'unknown_fisher',
      buyerId: buyerModel?.id ?? 'unknown_buyer',
      termsPrice: apiModel.termsPrice ?? 0,
      termsWeight: apiModel.termsWeight ?? 0,
      termsPricePerKg: apiModel.termsPricePerKg ?? 0,
      status: apiModel.status ?? 'pending',
      dateCreated: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      dateUpdated: apiModel.updatedAt ?? DateTime.now().toIso8601String(),
      hasReviewFromFisher: apiModel.fisherReview != null,
      hasReviewFromBuyer: apiModel.buyerReview != null,
      cancellationReason: apiModel.cancellationReason,
      product: productModel,
      buyer: buyerModel,
    );
  }

  // Request body creation (if needed)
  static Map<String, dynamic> toCreateBody(OrderModel order) {
    return {
      // TODO: Define create body when requirements are clear
      // For now simple placeholder or minimal fields
      'offer': order.offerId != null && order.offerId!.isNotEmpty
          ? '/api/offers/${order.offerId}'
          : null,
    };
  }
}
