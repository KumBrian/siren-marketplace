import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for catch filter (offers filtering and sorting)
class CatchFilterState {
  final List<String> pendingStatuses;
  final List<String> activeStatuses;
  final String activeSortBy;

  const CatchFilterState({
    this.pendingStatuses = const [],
    this.activeStatuses = const [],
    this.activeSortBy = 'descending',
  });

  int get totalFilters => activeStatuses.length;

  CatchFilterState copyWith({
    List<String>? pendingStatuses,
    List<String>? activeStatuses,
    String? activeSortBy,
  }) {
    return CatchFilterState(
      pendingStatuses: pendingStatuses ?? this.pendingStatuses,
      activeStatuses: activeStatuses ?? this.activeStatuses,
      activeSortBy: activeSortBy ?? this.activeSortBy,
    );
  }
}

/// Notifier for managing catch filter state
class CatchFilterNotifier extends StateNotifier<CatchFilterState> {
  CatchFilterNotifier() : super(const CatchFilterState());

  void toggleStatus(String status) {
    final pending = List<String>.from(state.pendingStatuses);
    if (pending.contains(status)) {
      pending.remove(status);
    } else {
      pending.add(status);
    }
    state = state.copyWith(pendingStatuses: pending);
  }

  void setSort(String sortBy) {
    state = state.copyWith(activeSortBy: sortBy);
  }

  void applyFilters() {
    state = state.copyWith(
      activeStatuses: List<String>.from(state.pendingStatuses),
    );
  }

  void clearAllFilters() {
    state = const CatchFilterState();
  }
}

/// Provider for catch filter state
final catchFilterProvider =
    StateNotifierProvider.autoDispose<CatchFilterNotifier, CatchFilterState>((
      ref,
    ) {
      return CatchFilterNotifier();
    });
