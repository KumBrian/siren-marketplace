import 'package:flutter_bloc/flutter_bloc.dart';

import 'catch_filter_state.dart';

class CatchFilterCubit extends Cubit<CatchFilterState> {
  CatchFilterCubit() : super(const CatchFilterState());

  void initializePendingStatuses() {
    emit(state.copyWith(pendingStatuses: Set.from(state.activeStatuses)));
  }

  void toggleStatus(String status) {
    final current = Set<String>.from(state.pendingStatuses);

    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }

    emit(state.copyWith(pendingStatuses: current));
  }

  void setSort(String sortBy) {
    final newActiveSortBy = state.activeSortBy == sortBy ? null : sortBy;

    emit(state.copyWith(activeSortBy: newActiveSortBy));
  }

  void applyFilters() {
    final newActiveStatuses = Set<String>.from(state.pendingStatuses);
    final totalFilters = newActiveStatuses.length;

    emit(
      state.copyWith(
        activeStatuses: newActiveStatuses,
        totalFilters: totalFilters,
      ),
    );
  }

  void clearAllFilters() {
    emit(const CatchFilterState());
  }
}
