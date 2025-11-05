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
    final newPendingSortBy = state.pendingSortBy == sortBy
        ? SortBy.none
        : sortBy;
    emit(state.copyWith(pendingSortBy: newPendingSortBy));
  }

  void applyFilters() {
    final newTotalStatuses = state.pendingStatuses.length;
    final newTotalFilters = newTotalStatuses;

    emit(
      state.copyWith(
        activeStatuses: state.pendingStatuses,
        activeSortBy: state.pendingSortBy,
        totalFilters: newTotalFilters,
      ),
    );
  }

  void clearAllFilters() {
    emit(
      state.copyWith(
        activeStatuses: const {},
        totalFilters: 0,
        activeSortBy: SortBy.none,
        pendingStatuses: const {},
        pendingSortBy: SortBy.none,
      ),
    );
  }
}
