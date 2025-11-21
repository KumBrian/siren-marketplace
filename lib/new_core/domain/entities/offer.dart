import 'package:equatable/equatable.dart';

import '../enums/offer_status.dart';
import '../enums/user_role.dart';
import '../value_objects/offer_terms.dart';

class Offer extends Equatable {
  final String id;
  final String catchId;
  final String fisherId;
  final String buyerId;
  final OfferTerms currentTerms;
  final OfferTerms? previousTerms;
  final OfferStatus status;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final UserRole? waitingFor;

  const Offer({
    required this.id,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    required this.currentTerms,
    this.previousTerms,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.waitingFor,
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

  // Domain Actions
  Offer accept() {
    if (!status.canBeAccepted) {
      throw StateError('Offer cannot be accepted in status: $status');
    }

    return copyWith(
      status: OfferStatus.accepted,
      dateUpdated: DateTime.now(),
      waitingFor: null,
    );
  }

  Offer reject() {
    if (!status.canBeRejected) {
      throw StateError('Offer cannot be rejected in status: $status');
    }

    return copyWith(
      status: OfferStatus.rejected,
      dateUpdated: DateTime.now(),
      waitingFor: null,
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

    return copyWith(
      currentTerms: newTerms,
      previousTerms: currentTerms,
      status: OfferStatus.pending,
      dateUpdated: DateTime.now(),
      waitingFor: nextWaitingFor,
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
  }) {
    return Offer(
      id: id,
      catchId: catchId,
      fisherId: fisherId,
      buyerId: buyerId,
      currentTerms: currentTerms ?? this.currentTerms,
      previousTerms: previousTerms ?? this.previousTerms,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      waitingFor: clearWaitingFor ? null : (waitingFor ?? this.waitingFor),
    );
  }

  @override
  List<Object?> get props => [
    id,
    catchId,
    fisherId,
    buyerId,
    currentTerms,
    previousTerms,
    status,
    dateCreated,
    dateUpdated,
    waitingFor,
  ];
}
