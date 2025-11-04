import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/types/enum.dart';

part 'offers_filter_state.dart';

class OffersFilterCubit extends Cubit<OffersFilterState> {
  OffersFilterCubit() : super(const OffersFilterState());

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

  void setSort(SortBy sortBy) {
    final newPendingSortBy = state.pendingSortBy == sortBy ? null : sortBy;

    emit(state.copyWith(pendingSortBy: newPendingSortBy));
  }

  void applyFilters() {
    final newActiveStatuses = Set<String>.from(state.pendingStatuses);
    final newActiveSortBy = state.pendingSortBy;
    final totalFilters = newActiveStatuses.length;

    emit(
      state.copyWith(
        activeStatuses: newActiveStatuses,
        totalFilters: totalFilters,
        activeSortBy: newActiveSortBy,
      ),
    );
  }

  void clearAllFilters() {
    emit(const OffersFilterState());
  }
}
