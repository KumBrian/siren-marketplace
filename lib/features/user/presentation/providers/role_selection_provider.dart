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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sessionService = sl<SessionService>();

      if (AppConfig.isApiMode) {
        // API Mode: User is already authenticated, just switch role

        await sessionService.switchRole(role);
      } else {
        // Demo/Local Mode: Fetch mock user and login

        final userRepository = sl<IUserRepository>();

        // 1. Fetch user based on role (Simulation for demo)
        final user = role == UserRole.fisher
            ? await userRepository.getFirstFisher()
            : await userRepository.getFirstBuyer();

        if (user == null) {
          throw Exception('No user found for role ${role.name}');
        }

        // 2. Login
        await sessionService.login(user);
      }

      // 3. Refresh global user provider and WAIT for it to complete
      // This ensures we have the new user data before we navigate.
      ref.invalidate(currentUserProvider);
      await ref.read(currentUserProvider.future);
    });
  }
}

final roleSelectionControllerProvider =
    AsyncNotifierProvider.autoDispose<RoleSelectionController, void>(
      RoleSelectionController.new,
    );

final selectedRoleProvider = StateProvider.autoDispose<UserRole>(
  (ref) => UserRole.unknown,
);
