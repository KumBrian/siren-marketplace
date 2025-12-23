import 'package:equatable/equatable.dart';

import '../enums/offer_status.dart';
import '../enums/user_role.dart';
import '../value_objects/offer_terms.dart';
import 'product.dart';
import 'user.dart';

class Offer extends Equatable {
  final String id;
  final String productId;
  final String fisherId;
  final String buyerId;
  final OfferTerms currentTerms;
  final OfferTerms? previousTerms;
  final OfferStatus status;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final UserRole? waitingFor;
  final bool hasUpdateForFisher;
  final bool hasUpdateForBuyer;
  final Product? product;
  final User? fisher;
  final User? buyer;

  const Offer({
    required this.id,
    required this.productId,
    required this.fisherId,
    required this.buyerId,
    required this.currentTerms,
    this.previousTerms,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.waitingFor,
    this.hasUpdateForFisher = true,
    this.hasUpdateForBuyer = true,
    this.product,
    this.fisher,
    this.buyer,
  });

  // Business Logic
  bool get isPending => status == OfferStatus.pending;

  bool get isAccepted => status == OfferStatus.accepted;

  bool get isRejected => status == OfferStatus.rejected;

  bool get isFinal => status.isFinal;

  bool get hasBeenCountered => previousTerms != null;

  bool isUsersTurn(String userId) {
    if (waitingFor == null) return false;

    if (waitingFor == UserRole.fisher) {
      return userId == fisherId;
    } else {
      return userId == buyerId;
    }
  }

  bool canBeCounteredBy(String userId) {
    return isPending && isUsersTurn(userId);
  }

  bool canBeAcceptedBy(String userId) {
    return isPending && isUsersTurn(userId);
  }

  bool canBeRejectedBy(String userId) {
    return isPending && isUsersTurn(userId);
  }

  bool hasUpdateFor(UserRole role) {
    if (role == UserRole.fisher) {
      return hasUpdateForFisher;
    } else {
      return hasUpdateForBuyer;
    }
  }

  // Domain Actions
  Offer accept() {
    if (!status.canBeAccepted) {
      throw StateError('Offer cannot be accepted in status: $status');
    }

    // Use waitingFor to determine who is accepting and notify the opposite party
    // If waitingFor is fisher (fisher's turn), buyer gets notification
    // If waitingFor is buyer (buyer's turn), fisher gets notification
    return copyWith(
      status: OfferStatus.accepted,
      dateUpdated: DateTime.now(),
      waitingFor: null,
      clearWaitingFor: true,
      hasUpdateForFisher: waitingFor == UserRole.buyer ? true : false,
      hasUpdateForBuyer: waitingFor == UserRole.fisher ? true : false,
    );
  }

  Offer reject() {
    if (!status.canBeRejected) {
      throw StateError('Offer cannot be rejected in status: $status');
    }

    // Use waitingFor to determine who is rejecting and notify the opposite party
    // If waitingFor is fisher (fisher's turn), buyer gets notification
    // If waitingFor is buyer (buyer's turn), fisher gets notification
    return copyWith(
      status: OfferStatus.rejected,
      dateUpdated: DateTime.now(),
      waitingFor: null,
      clearWaitingFor: true,
      hasUpdateForFisher: waitingFor == UserRole.buyer ? true : false,
      hasUpdateForBuyer: waitingFor == UserRole.fisher ? true : false,
    );
  }

  Offer counter({required OfferTerms newTerms, required String byUserId}) {
    if (!status.canBeCountered) {
      throw StateError('Offer cannot be countered in status: $status');
    }

    if (!isUsersTurn(byUserId)) {
      throw StateError('Not this user\'s turn to counter');
    }

    final nextWaitingFor = byUserId == fisherId
        ? UserRole.buyer
        : UserRole.fisher;

    // Set hasUpdate flag for the OTHER party (the one receiving the counter)
    // The countering party has already seen it (they created it), so hasUpdate=false
    return copyWith(
      currentTerms: newTerms,
      previousTerms: currentTerms,
      status: OfferStatus.pending,
      dateUpdated: DateTime.now(),
      waitingFor: nextWaitingFor,
      // If fisher counters, buyer needs notification (hasUpdateForBuyer=true)
      // If buyer counters, fisher needs notification (hasUpdateForFisher=true)
      hasUpdateForFisher: byUserId == buyerId ? true : false,
      hasUpdateForBuyer: byUserId == fisherId ? true : false,
    );
  }

  Offer copyWith({
    OfferTerms? currentTerms,
    OfferTerms? previousTerms,
    OfferStatus? status,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    UserRole? waitingFor,
    bool clearWaitingFor = false,
    bool? hasUpdateForFisher,
    bool? hasUpdateForBuyer,
    Product? product,
  }) {
    return Offer(
      id: id,
      productId: productId,
      fisherId: fisherId,
      buyerId: buyerId,
      currentTerms: currentTerms ?? this.currentTerms,
      previousTerms: previousTerms ?? this.previousTerms,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      waitingFor: clearWaitingFor ? null : (waitingFor ?? this.waitingFor),
      hasUpdateForFisher: hasUpdateForFisher ?? this.hasUpdateForFisher,
      hasUpdateForBuyer: hasUpdateForBuyer ?? this.hasUpdateForBuyer,
      product: product ?? this.product,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    fisherId,
    buyerId,
    currentTerms,
    previousTerms,
    status,
    dateCreated,
    dateUpdated,
    waitingFor,
    product,
  ];
}
