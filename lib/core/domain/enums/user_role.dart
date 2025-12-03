enum UserRole {
  fisher,
  buyer,
  unknown;

  String get displayName {
    switch (this) {
      case UserRole.fisher:
        return 'Fisher';
      case UserRole.buyer:
        return 'Buyer';
      case UserRole.unknown:
        return 'Unknown';
    }
  }

  bool get isFisher => this == UserRole.fisher;

  bool get isBuyer => this == UserRole.buyer;
}
