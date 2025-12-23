import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';

class DisplayItem {
  final String id;
  final String catchId;
  final OfferStatus status;
  final DateTime dateCreated;
  final double weight;
  final int price;
  final bool hasUpdate;
  final bool isOrder;

  DisplayItem({
    required this.id,
    required this.catchId,
    required this.status,
    required this.dateCreated,
    required this.weight,
    required this.price,
    required this.hasUpdate,
    required this.isOrder,
  });

  factory DisplayItem.fromOffer(Offer offer) {
    return DisplayItem(
      id: offer.id,
      catchId: offer.productId,
      status: offer.status,
      dateCreated: offer.dateCreated,
      weight: offer.currentTerms.weight.kilograms,
      price: offer.currentTerms.totalPrice.amount,
      hasUpdate: offer.hasUpdateForBuyer,
      isOrder: false,
    );
  }

  factory DisplayItem.fromOrder(Order order) {
    OfferStatus mappedStatus;
    switch (order.status) {
      case OrderStatus.accepted:
        mappedStatus = OfferStatus.accepted;
        break;
      case OrderStatus.completed:
        mappedStatus = OfferStatus.completed;
        break;
      case OrderStatus.cancelled:
        mappedStatus = OfferStatus.rejected;
        break;
    }

    return DisplayItem(
      id: order.id,
      catchId: order.catchId,
      status: mappedStatus,
      dateCreated: order.dateCreated,
      weight: (order.terms.weight.grams / 1000).toDouble(),
      price: order.terms.totalPrice.amount,
      hasUpdate: false,
      isOrder: true,
    );
  }
}
