enum UserRole {
  fisher,
  buyer;

  String get displayName {
    switch (this) {
      case UserRole.fisher:
        return 'Fisher';
      case UserRole.buyer:
        return 'Buyer';
    }
  }

  bool get isFisher => this == UserRole.fisher;

  bool get isBuyer => this == UserRole.buyer;
}
