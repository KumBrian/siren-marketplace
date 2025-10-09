// File: bloc/cubits/role_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/data_repo.dart';
import 'package:siren_marketplace/data/mock_repo.dart';

class UserRoleCubit extends Cubit<Role> {
  Repository _repository;

  // Constructor is fine as-is: it correctly starts at Role.unknown
  UserRoleCubit(this._repository) : super(Role.unknown);

  Repository get repository => _repository;

  // Remove the loadRole() method if you don't intend to read the role
  // from storage/network immediately, or keep it but ensure the
  // MockRepository returns Role.unknown by default.
  // Since you want the RoleScreen to show, we rely on the initial Role.unknown state.

  /// Dynamically change role & repository
  void setRole(Role role) {
    // 1. Update the repository with the new role implementation
    _repository = MockRepositoryImpl(role: role);

    // 2. Emit the new role, which triggers the GoRouter redirect.
    emit(role);
  }
}
