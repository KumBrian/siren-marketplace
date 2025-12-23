import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:uuid/uuid.dart';

class OrderSeeder {
  final Uuid _uuid = const Uuid();

  Future<List<Order>> seed() async {
    final orderRepository = sl<IOrderRepository>();
    final offerRepository = sl<IOfferRepository>();

    final existing = await orderRepository.getAllOrders();
    if (existing.isNotEmpty) {
      print('Orders exist. Skipping.');
      return [];
    }

    final allOffers = await offerRepository.getAllOffers();

    // Only process pending offers where it's the fisher's turn
    final offersToAccept = allOffers
        .where(
          (o) =>
              o.status == OfferStatus.pending &&
              o.waitingFor == UserRole.fisher,
        )
        .toList();

    print('Creating ${offersToAccept.length} orders from pending offers...');

    final List<Order> orders = [];

    for (final offer in offersToAccept) {
      // Create order directly without negotiation service
      final order = Order(
        id: 'ORD${_uuid.v4().substring(0, 8).toUpperCase()}',
        offerId: offer.id,
        catchId: offer.productId,
        fisherId: offer.fisherId,
        buyerId: offer.buyerId,
        terms: offer.currentTerms,
        status: OrderStatus.accepted,
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
      );

      // Update offer status to accepted
      final acceptedOffer = offer.copyWith(
        status: OfferStatus.accepted,
        dateUpdated: DateTime.now(),
      );

      await orderRepository.create(order);
      await offerRepository.update(acceptedOffer);
      orders.add(order);
    }

    print('${orders.length} orders seeded.');
    return orders;
  }
}
