import '../entities/offer.dart';
import '../entities/order.dart';
import '../enums/offer_status.dart';
import '../enums/order_status.dart';
import '../enums/user_role.dart';
import '../repositories/i_catch_repository.dart';
import '../repositories/i_offer_repository.dart';
import '../repositories/i_order_repository.dart';
import '../value_objects/offer_terms.dart';

/// Service handling offer negotiation workflows and business rules
class NegotiationService {
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;
  final ICatchRepository _catchRepository;

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
      id: _generateId(),
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

    // Execute in transaction
    return await _offerRepository.transaction(() async {
      // Accept offer
      final acceptedOffer = offer.accept();
      await _offerRepository.update(acceptedOffer);

      // Reduce catch available weight
      final updatedCatch = catchItem.reduceAvailableWeight(
        offer.currentTerms.weight,
      );
      await _catchRepository.update(updatedCatch);

      // Create order
      final order = Order(
        id: _generateId(),
        offerId: acceptedOffer.id,
        catchId: acceptedOffer.catchId,
        fisherId: acceptedOffer.fisherId,
        buyerId: acceptedOffer.buyerId,
        terms: acceptedOffer.currentTerms,
        status: OrderStatus.active,
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
      );

      await _orderRepository.create(order);
      return order;
    });
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

  /// Get pending offers requiring user's action
  Future<List<Offer>> getPendingOffersForUser(String userId) async {
    return await _offerRepository.getPendingForUser(userId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
