import 'package:equatable/equatable.dart';

import '../enums/order_status.dart';
import '../value_objects/offer_terms.dart';

class Order extends Equatable {
  final String id;
  final String offerId;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final OfferTerms terms;
  final OrderStatus status;
  final DateTime dateCreated;
  final DateTime dateUpdated;

  // Review tracking
  final bool hasReviewFromFisher;
  final bool hasReviewFromBuyer;

  const Order({
    required this.id,
    required this.offerId,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.terms,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.hasReviewFromFisher = false,
    this.hasReviewFromBuyer = false,
  });

  // Business Logic
  bool get isActive => status == OrderStatus.active;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canBeReviewed => status.canBeReviewed;

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
    if (status != OrderStatus.active) {
      throw StateError('Can only complete active orders');
    }

    return copyWith(status: OrderStatus.completed, dateUpdated: DateTime.now());
  }

  Order markAsCancelled() {
    if (status != OrderStatus.active) {
      throw StateError('Can only cancel active orders');
    }

    return copyWith(status: OrderStatus.cancelled, dateUpdated: DateTime.now());
  }

  Order markAsReviewedBy(String userId) {
    if (userId == fisherId) {
      return copyWith(hasReviewFromFisher: true);
    } else if (userId == buyerId) {
      return copyWith(hasReviewFromBuyer: true);
    }

    throw ArgumentError('User is not part of this order');
  }

  Order copyWith({
    OfferTerms? terms,
    OrderStatus? status,
    DateTime? dateUpdated,
    bool? hasReviewFromFisher,
    bool? hasReviewFromBuyer,
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
      hasReviewFromFisher: hasReviewFromFisher ?? this.hasReviewFromFisher,
      hasReviewFromBuyer: hasReviewFromBuyer ?? this.hasReviewFromBuyer,
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
    hasReviewFromFisher,
    hasReviewFromBuyer,
  ];
}
