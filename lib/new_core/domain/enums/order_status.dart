enum OrderStatus {
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.active:
        return 'Active';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this == OrderStatus.active;

  bool get isCompleted => this == OrderStatus.completed;

  bool get canBeReviewed => this == OrderStatus.completed;
}
