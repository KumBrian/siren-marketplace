import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(1);

  void changeIndex(int index) {
    emit(index);
  }

  void reset() => emit(1);
}
