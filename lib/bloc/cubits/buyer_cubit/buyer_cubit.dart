import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/mock_repo.dart';

class BuyerCubit extends Cubit<Buyer?> {
  // The type for the constructor injection is already correct
  final Repository repository;

  BuyerCubit(this.repository) : super(null);

  Future<void> loadBuyer() async {
    final buyer = await repository.getBuyer();
    emit(buyer);
  }
}
