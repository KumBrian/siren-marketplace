import 'package:flutter_bloc/flutter_bloc.dart';

import 'catch_filter_state.dart';

class CatchFilterCubit extends Cubit<CatchFilterState> {
  CatchFilterCubit() : super(const CatchFilterState());

  void toggleStatus(String status) {
    final current = Set<String>.from(state.selectedStatuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    emit(state.copyWith(selectedStatuses: current));
  }

  void setSort(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
  }

  void clear() {
    emit(const CatchFilterState());
  }
}
