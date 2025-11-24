import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/enums/catch_status.dart';
import '../../../../../new_core/domain/repositories/i_catch_repository.dart';
import 'fisher_catch_list_state.dart';

class FisherCatchListCubit extends Cubit<FisherCatchListState> {
  final ICatchRepository _catchRepository;
  String? _currentFisherId;
  List<Catch> _allCatches = [];

  FisherCatchListCubit({ICatchRepository? catchRepository})
    : _catchRepository = catchRepository ?? DI().catchRepository,
      super(const FisherCatchListInitial());

  Future<void> loadCatches(String fisherId) async {
    _currentFisherId = fisherId;
    emit(const FisherCatchListLoading());

    try {
      _allCatches = await _catchRepository.getByFisherId(fisherId);
      emit(FisherCatchListLoaded(catches: _allCatches));
    } catch (e) {
      emit(FisherCatchListError('Failed to load catches: $e'));
    }
  }

  void filterByStatus(CatchStatus? status) {
    if (status == null) {
      emit(FisherCatchListLoaded(catches: _allCatches));
    } else {
      final filtered = _allCatches.where((c) => c.status == status).toList();
      emit(FisherCatchListLoaded(catches: filtered, filterStatus: status));
    }
  }

  Future<void> deleteCatch(String catchId) async {
    final currentState = state;
    if (currentState is! FisherCatchListLoaded) return;

    try {
      // Mark as removed (not full delete)
      final catchToRemove = _allCatches.firstWhere((c) => c.id == catchId);
      final removed = catchToRemove.markAsRemoved();
      await _catchRepository.update(removed);

      // Refresh list
      if (_currentFisherId != null) {
        await loadCatches(_currentFisherId!);
      }
    } catch (e) {
      emit(FisherCatchListError('Failed to delete catch: $e'));
      emit(currentState); // Rollback
    }
  }

  Future<void> refresh() async {
    if (_currentFisherId != null) {
      await loadCatches(_currentFisherId!);
    }
  }
}
