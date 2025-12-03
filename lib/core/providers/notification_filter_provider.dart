import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';

/// State for notification filters
class NotificationFilterState {
  final Set<OfferStatus> activeStatuses;
  final Set<OfferStatus> pendingStatuses;
  final String activeSortBy; // "ascending" or "descending"

  const NotificationFilterState({
    this.activeStatuses = const {},
    this.pendingStatuses = const {},
    this.activeSortBy = "descending", // Default: newest first
  });

  NotificationFilterState copyWith({
    Set<OfferStatus>? activeStatuses,
    Set<OfferStatus>? pendingStatuses,
    String? activeSortBy,
  }) {
    return NotificationFilterState(
      activeStatuses: activeStatuses ?? this.activeStatuses,
      pendingStatuses: pendingStatuses ?? this.pendingStatuses,
      activeSortBy: activeSortBy ?? this.activeSortBy,
    );
  }
}

/// Notifier for notification filters
class NotificationFilterNotifier
    extends StateNotifier<NotificationFilterState> {
  NotificationFilterNotifier() : super(const NotificationFilterState());

  void toggleStatus(OfferStatus status) {
    final newPending = Set<OfferStatus>.from(state.pendingStatuses);
    if (newPending.contains(status)) {
      newPending.remove(status);
    } else {
      newPending.add(status);
    }
    state = state.copyWith(pendingStatuses: newPending);
  }

  void applyFilters() {
    state = state.copyWith(activeStatuses: state.pendingStatuses);
  }

  void clearAllFilters() {
    state = const NotificationFilterState();
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(activeSortBy: sortBy);
  }
}

/// Provider for notification filters
final notificationFilterProvider =
    StateNotifierProvider<NotificationFilterNotifier, NotificationFilterState>(
      (ref) => NotificationFilterNotifier(),
    );
