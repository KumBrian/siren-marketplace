import '../entities/offer.dart';
import '../entities/order.dart';
import '../enums/offer_status.dart';
import '../enums/order_status.dart';
import '../enums/user_role.dart';
import '../repositories/i_catch_repository.dart';
import '../repositories/i_offer_repository.dart';
import '../repositories/i_order_repository.dart';
import '../value_objects/offer_terms.dart';
import 'package:uuid/uuid.dart';

/// Service handling offer negotiation workflows and business rules
class NegotiationService {
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;
  final ICatchRepository _catchRepository;
  static const _uuid = Uuid();

  NegotiationService({
    required IOfferRepository offerRepository,
    required IOrderRepository orderRepository,
    required ICatchRepository catchRepository,
  }) : _offerRepository = offerRepository,
       _orderRepository = orderRepository,
       _catchRepository = catchRepository;

  /// Create a new offer for a catch
  Future<Offer> createOffer({
    required String catchId,
    required String buyerId,
    required String fisherId,
    required OfferTerms terms,
  }) async {
    // Validate catch exists and can receive offers
    final catchItem = await _catchRepository.getById(catchId);
    if (catchItem == null) {
      throw ArgumentError('Catch not found');
    }

    if (!catchItem.canReceiveOffers) {
      throw StateError(
        'Catch cannot receive offers (status: ${catchItem.status})',
      );
    }

    // Validate weight doesn't exceed available
    if (terms.weight > catchItem.availableWeight) {
      throw ArgumentError(
        'Offer weight (${terms.weight}) exceeds available weight (${catchItem.availableWeight})',
      );
    }

    // Create offer
    final offer = Offer(
      id: _generateOfferId(),
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      currentTerms: terms,
      previousTerms: null,
      status: OfferStatus.pending,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      waitingFor: UserRole.fisher, // Fisher must respond first
    );

    await _offerRepository.create(offer);
    return offer;
  }

  /// Accept an offer and create an order
  Future<Order> acceptOffer({
    required String offerId,
    required String userId,
  }) async {
    final offer = await _offerRepository.getById(offerId);
    if (offer == null) {
      throw ArgumentError('Offer not found');
    }

    // Validate offer can be accepted
    if (!offer.canBeAcceptedBy(userId)) {
      throw StateError('Offer cannot be accepted by this user');
    }

    // Validate catch still exists and is available
    final catchItem = await _catchRepository.getById(offer.catchId);
    if (catchItem == null) {
      throw StateError('Associated catch not found');
    }

    if (!catchItem.canReceiveOffers) {
      throw StateError('Catch is no longer available');
    }

    // Accept offer (no transaction wrapper - individual operations are atomic)
    final acceptedOffer = offer.accept();
    await _offerRepository.update(acceptedOffer);

    // Reduce catch available weight
    final updatedCatch = catchItem.reduceAvailableWeight(
      offer.currentTerms.weight,
    );
    await _catchRepository.update(updatedCatch);

    // Create order
    final order = Order(
      id: _generateOrderId(),
      offerId: acceptedOffer.id,
      catchId: acceptedOffer.catchId,
      fisherId: acceptedOffer.fisherId,
      buyerId: acceptedOffer.buyerId,
      terms: acceptedOffer.currentTerms,
      status: OrderStatus.accepted,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
    );

    await _orderRepository.create(order);
    return order;
  }

  /// Reject an offer
  Future<Offer> rejectOffer({
    required String offerId,
    required String userId,
  }) async {
    final offer = await _offerRepository.getById(offerId);
    if (offer == null) {
      throw ArgumentError('Offer not found');
    }

    if (!offer.canBeRejectedBy(userId)) {
      throw StateError('Offer cannot be rejected by this user');
    }

    final rejectedOffer = offer.reject();
    await _offerRepository.update(rejectedOffer);
    return rejectedOffer;
  }

  /// Counter an offer with new terms
  Future<Offer> counterOffer({
    required String offerId,
    required String userId,
    required OfferTerms newTerms,
  }) async {
    final offer = await _offerRepository.getById(offerId);
    if (offer == null) {
      throw ArgumentError('Offer not found');
    }

    if (!offer.canBeCounteredBy(userId)) {
      throw StateError('Offer cannot be countered by this user');
    }

    // Validate new terms are different
    if (!newTerms.isDifferentFrom(offer.currentTerms)) {
      throw ArgumentError('New terms must be different from current terms');
    }

    // Validate weight against catch availability
    final catchItem = await _catchRepository.getById(offer.catchId);
    if (catchItem == null) {
      throw StateError('Associated catch not found');
    }

    if (newTerms.weight > catchItem.availableWeight) {
      throw ArgumentError('Counter offer weight exceeds available weight');
    }

    final counteredOffer = offer.counter(newTerms: newTerms, byUserId: userId);

    await _offerRepository.update(counteredOffer);
    return counteredOffer;
  }

  /// Relist an order to the marketplace
  /// Cancels the order, rejects the offer, and restores catch weight
  Future<void> relistOrder({
    required String orderId,
    required String reason,
  }) async {
    final order = await _orderRepository.getById(orderId);

    // Validate order can be cancelled
    if (order.status != OrderStatus.accepted) {
      throw StateError('Can only relist active orders');
    }

    // 1. Cancel order with reason
    final cancelledOrder = order.markAsCancelled(reason: reason);
    await _orderRepository.update(cancelledOrder);

    // 2. Reject the related offer
    final offer = await _offerRepository.getById(order.offerId);
    if (offer != null) {
      final rejectedOffer = offer.copyWith(
        status: OfferStatus.rejected,
        waitingFor: null,
      );
      await _offerRepository.update(rejectedOffer);
    }

    // 3. Restore catch weight
    final catchItem = await _catchRepository.getById(order.catchId);
    if (catchItem != null) {
      final restoredCatch = catchItem.copyWith(
        availableWeight: catchItem.availableWeight + order.terms.weight,
      );
      await _catchRepository.update(restoredCatch);
    }
  }

  /// Get pending offers requiring user's action
  Future<List<Offer>> getPendingOffersForUser(String userId) async {
    return await _offerRepository.getPendingForUser(userId);
  }

  String _generateOfferId() {
    // Generate OFF prefix + 8 UUID characters
    return 'OFF${_uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase()}';
  }

  String _generateOrderId() {
    // Generate ODD prefix + 8 UUID characters
    return 'ODD${_uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase()}';
  }
}
