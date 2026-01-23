import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/features/user/presentation/providers/role_selection_provider.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/role_button.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';

// Provider for the currently selected role
final selectedRoleProvider = StateProvider<UserRole>((ref) => UserRole.unknown);

class RoleScreen extends ConsumerWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);

    // Listen to the controller state for side effects (navigation/error)
    ref.listen<AsyncValue<void>>(roleSelectionControllerProvider, (
      previous,
      next,
    ) {
      // RoleScreen listener: next state = next
      if (next.hasError) {
        // RoleScreen listener: Error
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: "Selection Error",
            message: next.error.toString(),
          ),
        );
        ref.read(selectedRoleProvider.notifier).state = UserRole.unknown;
      } else if (!next.isLoading && !next.hasError && next.hasValue) {
        // We read the provider here to get the LATEST value
        // even if the widget rebuilt.
        final currentSelectedRole = ref.read(selectedRoleProvider);

        // Success! Navigate based on selected role
        if (currentSelectedRole == UserRole.buyer) {
          context.go('/buyer');
        } else if (currentSelectedRole == UserRole.fisher) {
          context.go('/fisher');
        }
      }
    });

    final state = ref.watch(roleSelectionControllerProvider);
    final bool isLoading = state.isLoading;

    // Disable button if loading or unknown selection
    final buttonDisabled = isLoading || selectedRole == UserRole.unknown;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/siren_logo.png',
          width: 100,
          height: 100,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBlue,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Please, select your role to continue.",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RoleButton(
                      title: "Fisher",
                      icon: "assets/icons/fisher.png",
                      isActive: selectedRole == UserRole.fisher,
                      onPressed: () =>
                          ref.read(selectedRoleProvider.notifier).state =
                              UserRole.fisher,
                    ),
                    const SizedBox(height: 20),
                    RoleButton(
                      title: "Buyer",
                      icon: "assets/icons/buyer.png",
                      isActive: selectedRole == UserRole.buyer,
                      onPressed: () =>
                          ref.read(selectedRoleProvider.notifier).state =
                              UserRole.buyer,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Continue Button (Finalize selection and navigate)
                CustomButton(
                  title: "Continue",
                  disabled: buttonDisabled,
                  suffixIcon: CupertinoIcons.chevron_forward,
                  onPressed: () {
                    if (selectedRole != UserRole.unknown) {
                      ref
                          .read(roleSelectionControllerProvider.notifier)
                          .selectRole(selectedRole);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
