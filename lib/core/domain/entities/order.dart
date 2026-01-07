import 'package:equatable/equatable.dart';

import '../enums/order_status.dart';
import '../value_objects/offer_terms.dart';
import 'product.dart';
import 'user.dart';
import 'review.dart';

class Order extends Equatable {
  final String id;
  final String? offerId;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final OfferTerms terms;
  final OrderStatus status;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  // Order number for display
  final String? orderNumber;

  // Embedded product data
  final Product? product;

  // Embedded buyer data
  final User? buyer;

  // Review objects
  final Review? fisherReview;
  final Review? buyerReview;

  // Cancellation tracking
  final String? cancellationReason;

  const Order({
    required this.id,
    this.offerId,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.terms,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.orderNumber,
    this.product,
    this.buyer,
    this.fisherReview,
    this.buyerReview,
    this.cancellationReason,
  });

  // Business Logic
  bool get isActive => status == OrderStatus.accepted;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canBeReviewed => status.canBeReviewed;

  bool get hasReviewFromFisher => fisherReview != null;
  bool get hasReviewFromBuyer => buyerReview != null;

  bool canBeReviewedBy(String userId) {
    if (!canBeReviewed) return false;

    if (userId == fisherId) {
      return !hasReviewFromFisher;
    } else if (userId == buyerId) {
      return !hasReviewFromBuyer;
    }

    return false;
  }

  bool hasReview(String reviewerId, String reviewedUserId) {
    if (reviewerId == fisherId && reviewedUserId == buyerId) {
      return hasReviewFromFisher;
    } else if (reviewerId == buyerId && reviewedUserId == fisherId) {
      return hasReviewFromBuyer;
    }
    return false;
  }

  String getCounterpartyId(String userId) {
    if (userId == fisherId) return buyerId;
    if (userId == buyerId) return fisherId;
    throw ArgumentError('User is not part of this order');
  }

  // Domain Actions
  Order markAsCompleted() {
    if (status != OrderStatus.accepted) {
      throw StateError('Can only complete active orders');
    }

    return copyWith(status: OrderStatus.completed, dateUpdated: DateTime.now());
  }

  Order markAsCancelled({String? reason}) {
    if (status != OrderStatus.accepted) {
      throw StateError('Can only cancel active orders');
    }

    return copyWith(
      status: OrderStatus.cancelled,
      dateUpdated: DateTime.now(),
      cancellationReason: reason,
    );
  }

  /* 
   * Note: manual hasReviewFrom... flag setting is deprecated in favor of 
   * setting the actual review object, but we keep copyWith simple.
   * If strictly needed, we can add methods to "attach" a review.
   */

  Order copyWith({
    OfferTerms? terms,
    OrderStatus? status,
    DateTime? dateUpdated,
    String? cancellationReason,
    String? orderNumber,
    Product? product,
    User? buyer,
    Review? fisherReview,
    Review? buyerReview,
    // Legacy support arguments (ignored if review obj provided, or used to nullify?)
    // Simpler to just support replacing the whole object
  }) {
    return Order(
      id: id,
      offerId: offerId,
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      orderNumber: orderNumber ?? this.orderNumber,
      product: product ?? this.product,
      buyer: buyer ?? this.buyer,
      fisherReview: fisherReview ?? this.fisherReview,
      buyerReview: buyerReview ?? this.buyerReview,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    offerId,
    catchId,
    fisherId,
    buyerId,
    terms,
    status,
    dateCreated,
    dateUpdated,
    orderNumber,
    product,
    buyer,
    fisherReview,
    buyerReview,
    cancellationReason,
  ];
}
