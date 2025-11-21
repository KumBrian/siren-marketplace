enum OfferStatus {
  pending,
  accepted,
  rejected,
  expired;

  String get displayName {
    switch (this) {
      case OfferStatus.pending:
        return 'Pending';
      case OfferStatus.accepted:
        return 'Accepted';
      case OfferStatus.rejected:
        return 'Rejected';
      case OfferStatus.expired:
        return 'Expired';
    }
  }

  bool get isActive => this == OfferStatus.pending;

  bool get isFinal =>
      this == OfferStatus.accepted || this == OfferStatus.rejected;

  bool get canBeCountered => this == OfferStatus.pending;

  bool get canBeAccepted => this == OfferStatus.pending;

  bool get canBeRejected => this == OfferStatus.pending;
}
