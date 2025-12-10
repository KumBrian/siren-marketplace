import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/config/app_config.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';

class RoleSelectionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state to load
  }

  Future<void> selectRole(UserRole role) async {
    print('RoleSelectionController.selectRole called with $role');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      print('RoleSelectionController.selectRole - starting guard');
      final sessionService = sl<SessionService>();

      if (AppConfig.isApiMode) {
        // API Mode: User is already authenticated, just switch role
        print('RoleSelectionController - API mode: switching role');
        await sessionService.switchRole(role);
        print('RoleSelectionController - Role switched successfully');
      } else {
        // Demo/Local Mode: Fetch mock user and login
        print('RoleSelectionController - Demo/Local mode: fetching mock user');
        final userRepository = sl<IUserRepository>();

        // 1. Fetch user based on role (Simulation for demo)
        final user = role == UserRole.fisher
            ? await userRepository.getFirstFisher()
            : await userRepository.getFirstBuyer();

        if (user == null) {
          print('RoleSelectionController.selectRole - User not found');
          throw Exception('No user found for role ${role.name}');
        }
        print('RoleSelectionController.selectRole - User found: ${user.id}');

        // 2. Login
        await sessionService.login(user);
        print('RoleSelectionController.selectRole - Login successful');
      }

      // 3. Refresh global user provider and WAIT for it to complete
      // This ensures we have the new user data before we navigate.
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
      print(
        'RoleSelectionController.selectRole - Provider invalidated and refreshed',
      );
    });
    print('RoleSelectionController.selectRole - state updated to: $state');
  }
}

final roleSelectionControllerProvider =
    AsyncNotifierProvider.autoDispose<RoleSelectionController, void>(
      RoleSelectionController.new,
    );

final selectedRoleProvider = StateProvider.autoDispose<UserRole>(
  (ref) => UserRole.unknown,
);
