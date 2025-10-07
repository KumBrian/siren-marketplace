import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/constants/types.dart';

class RoleCubit extends Cubit<Role> {
  RoleCubit() : super(Role.unknown);

  void selectRole(Role role) {
    emit(role);
  }
}
