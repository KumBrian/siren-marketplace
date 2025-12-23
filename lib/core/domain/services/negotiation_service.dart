import '../entities/offer.dart';
import '../entities/order.dart';
import '../enums/offer_status.dart';
import '../enums/order_status.dart';
import '../enums/user_role.dart';
import '../repositories/i_catch_repository.dart';
import '../repositories/i_product_repository.dart';
import '../entities/product.dart';
import '../repositories/i_offer_repository.dart';
import '../repositories/i_order_repository.dart';
import '../value_objects/offer_terms.dart';
import 'message_service.dart';
import 'package:uuid/uuid.dart';

/// Service handling offer negotiation workflows and business rules
class NegotiationService {
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;
  final ICatchRepository _catchRepository;
  final IProductRepository _productRepository;
  final MessageService?
  _messageService; // Optional for now to avoid breaking changes
  static const _uuid = Uuid();

  NegotiationService({
    required IOfferRepository offerRepository,
    required IOrderRepository orderRepository,
    required ICatchRepository catchRepository,
    required IProductRepository productRepository,
    MessageService? messageService,
  }) : _offerRepository = offerRepository,
       _orderRepository = orderRepository,
       _catchRepository = catchRepository,
       _productRepository = productRepository,
       _messageService = messageService;

  /// Create a new offer for a catch or product
  Future<Offer> createOffer({
    required String productId,
    required String buyerId,
    required String fisherId,
    required OfferTerms terms,
  }) async {
    // Try to find as product first (migration preference)
    final productResult = await _productRepository.getProductById(productId);
    // Check product first
    double availableWeightGrams = 0;
    Product? product;
    if (productResult.isRight) {
      product = productResult.getOrElse(() => null);
    }

    if (product != null) {
      availableWeightGrams = product.availableWeight.grams.toDouble();
      // Product doesn't have explicit "canReceiveOffers" other than weight > 0 and implicit status
      if (availableWeightGrams <= 0) {
        throw StateError('Product available weight is zero');
      }
    } else {
      // Fallback to Catch
      final catchItem = await _catchRepository.getById(productId);
      if (catchItem == null) {
        throw ArgumentError('Product/Catch not found');
      }

      if (!catchItem.canReceiveOffers) {
        throw StateError(
          'Catch cannot receive offers (status: ${catchItem.status})',
        );
      }
      availableWeightGrams = catchItem.availableWeight.grams.toDouble();
    }

    // Validate weight doesn't exceed available
    if (terms.weight.grams > availableWeightGrams) {
      throw ArgumentError(
        'Offer weight (${terms.weight}) exceeds available weight ($availableWeightGrams)',
      );
    }

    // Create offer
    final offer = Offer(
      id: _generateOfferId(),
      productId: productId,
      fisherId: fisherId,
      buyerId: buyerId,
      currentTerms: terms,
      previousTerms: null,
      status: OfferStatus.pending,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      waitingFor: UserRole.fisher, // Fisher must respond first
      product: product,
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
    final catchItem = await _catchRepository.getById(offer.productId);
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
      catchId: acceptedOffer.productId,
      fisherId: acceptedOffer.fisherId,
      buyerId: acceptedOffer.buyerId,
      terms: acceptedOffer.currentTerms,
      status: OrderStatus.accepted,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
    );

    await _orderRepository.create(order);

    // Send automatic message to both users
    try {
      await _messageService?.sendOfferAcceptedMessage(order);
    } catch (e) {
      // Log error but don't fail the order creation
      print('Failed to send offer accepted message: $e');
    }

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
    // Validate weight against product/catch availability
    double availableWeightGrams = 0;

    // Check product first
    final productResult = await _productRepository.getProductById(
      offer.productId,
    );

    Product? product;
    if (productResult.isRight) {
      product = productResult.getOrElse(() => null);
    }

    if (product != null) {
      availableWeightGrams = product.availableWeight.grams.toDouble();
    } else {
      // Check catch
      final catchItem = await _catchRepository.getById(offer.productId);
      if (catchItem == null) {
        throw StateError('Associated product/catch not found');
      }
      availableWeightGrams = catchItem.availableWeight.grams.toDouble();
    }

    if (newTerms.weight.grams > availableWeightGrams) {
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
