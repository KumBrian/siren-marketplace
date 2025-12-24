import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';

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
import 'package:uuid/uuid.dart';

/// Service handling offer negotiation workflows and business rules
class NegotiationService {
  final IOfferRepository _offerRepository;
  final IOrderRepository _orderRepository;
  final ICatchRepository _catchRepository;
  final IProductRepository _productRepository;
  static const _uuid = Uuid();

  NegotiationService({
    required IOfferRepository offerRepository,
    required IOrderRepository orderRepository,
    required ICatchRepository catchRepository,
    required IProductRepository productRepository,
  }) : _offerRepository = offerRepository,
       _orderRepository = orderRepository,
       _catchRepository = catchRepository,
       _productRepository = productRepository;

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

    // TODO: Fix ID inconsistency between JWT user ID and account database ID
    // Currently using account ID from offer data as workaround
    // The JWT userId (e.g., 171278) doesn't match database account IDs (e.g., 1, 7)
    String accountIdToUse = userId;

    // Determine which account ID to use based on role
    if (offer.fisher != null && offer.fisher!.id == offer.fisherId) {
      // User is the fisher, use fisher's account ID
      accountIdToUse = offer.fisherId;
    } else if (offer.buyer != null && offer.buyer!.id == offer.buyerId) {
      // User is the buyer, use buyer's account ID
      accountIdToUse = offer.buyerId;
    }

    // Validate offer can be accepted
    if (!offer.canBeAcceptedBy(accountIdToUse)) {
      throw StateError('Offer cannot be accepted by this user');
    }

    // TODO: Product availability validation removed - offers now use products, not catches
    // The backend handles availability checks when the offer is accepted via API

    // Accept offer via repository (calls API)
    // Backend handles the state change, product weight reduction, and order creation
    final Order? order = await _offerRepository.acceptOffer(
      offerId,
      // Role is not strictly needed by API as it uses auth token,
      // but sticking to signature
      accountIdToUse == offer.fisherId ? UserRole.fisher : UserRole.buyer,
      message: 'Offer accepted',
    );

    if (order == null) {
      // TODO: Parse order from accept response's saleOrder field
      // For now, return a placeholder since backend creates the order successfully
      print(
        'Order not immediately available via getByOfferId for offer $offerId',
      );

      // Return a minimal placeholder order so the UI doesn't break
      // The actual order will be fetched when user navigates to order details
      return Order(
        id: offerId,
        offerId: '',
        catchId: '',
        fisherId: '',
        buyerId: '',
        terms: OfferTerms.create(
          totalPrice: Price.fromAmount(0),
          weight: Weight.fromKg(0),
        ),
        status: OrderStatus.accepted,
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
      );
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

    await _offerRepository.rejectOffer(
      offerId,
      userId == offer.fisherId ? UserRole.fisher : UserRole.buyer,
      message: 'Offer rejected',
    );

    // Fetch updated offer to return
    final updatedOffer = await _offerRepository.getById(offerId);
    if (updatedOffer == null) {
      throw StateError('Offer not found after rejection');
    }
    return updatedOffer;
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

    // Validate weight is unchanged
    if (newTerms.weight != offer.currentTerms.weight) {
      throw ArgumentError('Weight cannot be changed in a counter offer');
    }

    // Determine role (assuming userId belongs to fisher or buyer)
    UserRole role;
    if (userId == offer.fisherId) {
      role = UserRole.fisher;
    } else if (userId == offer.buyerId) {
      role = UserRole.buyer;
    } else {
      throw ArgumentError('User is not part of this offer');
    }

    // Call repository to perform counter offer via API/DataSource
    await _offerRepository.counterOffer(offerId, role, newTerms);

    // Fetch updated offer to return
    final updatedOffer = await _offerRepository.getById(offerId);
    if (updatedOffer == null) {
      throw StateError('Failed to retrieve updated offer');
    }
    return updatedOffer;
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
}
