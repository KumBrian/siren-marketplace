import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/features/fisher/data/fisher_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

part 'fisher_state.dart';

class FisherCubit extends Cubit<FisherState> {
  final FisherRepository repository;

  FisherCubit({required this.repository}) : super(FisherInitial());

  Future<void> fetchFisher(String fisherId) async {
    emit(FisherLoading());
    try {
      final fisher = await repository.getFisherById(fisherId);
      emit(FisherLoaded(fisher));
    } catch (e) {
      emit(FisherError(e.toString()));
    }
  }
}
