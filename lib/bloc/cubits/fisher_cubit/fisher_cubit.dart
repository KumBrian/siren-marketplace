import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/mock_repo.dart';

class FisherCubit extends Cubit<Fisher?> {
  final Repository repository;

  FisherCubit(this.repository) : super(null);

  Future<void> loadFisher() async {
    final fisher = await repository.getFisher();
    emit(fisher);
  }
}
