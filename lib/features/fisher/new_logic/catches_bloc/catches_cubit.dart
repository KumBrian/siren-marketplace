import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/catch.dart';
import '../../../../core/domain/repositories/i_catch_repository.dart';

part 'catches_state.dart';

class CatchesCubit extends Cubit<CatchesState> {
  final ICatchRepository repository;

  CatchesCubit({required this.repository}) : super(const CatchesState());

  Future<void> loadForFisher(String fisherId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getByFisherId(fisherId);
      emit(state.copyWith(loading: false, catches: results));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
