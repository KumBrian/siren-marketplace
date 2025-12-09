enum CatchStatus {
  available,
  soldOut,
  expired,
  removed,
  draft;

  String get displayName {
    switch (this) {
      case CatchStatus.available:
        return 'Available';
      case CatchStatus.soldOut:
        return 'Sold Out';
      case CatchStatus.expired:
        return 'Expired';
      case CatchStatus.removed:
        return 'Removed';
      case CatchStatus.draft:
        return 'Draft';
    }
  }

  bool get isActive => this == CatchStatus.available;

  bool get canReceiveOffers => this == CatchStatus.available;

  bool get shouldBeDeletedAfterGracePeriod => this == CatchStatus.expired;
}
