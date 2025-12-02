enum OrderStatus {
  accepted,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isAccepted => this == OrderStatus.accepted;

  bool get isCompleted => this == OrderStatus.completed;

  bool get canBeReviewed => this == OrderStatus.completed;
}
