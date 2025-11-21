import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/role_button.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  // Local state to hold the currently selected role for UI
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
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
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              // Initialize selection on first load if authenticated
              if (state is AuthAuthenticated && _selectedRole == null) {
                setState(() {
                  _selectedRole = state.currentRole;
                });
              }

              // If there's an error, reset selection on the next frame (safe)
              if (state is AuthError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedRole = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                });
              }

              if (state is AuthAuthenticated) {
                // safe navigation after state settled
                if (state.currentRole == UserRole.buyer) {
                  // use addPostFrame to be extra safe
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.go('/buyer');
                  });
                } else if (state.currentRole == UserRole.fisher) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.go('/fisher');
                  });
                }
              }
            },
            builder: (context, state) {
              final bool isLoading = state is AuthLoading;
              final bool isError = state is AuthError;

              // Disable button if loading or unknown selection
              final buttonDisabled = isLoading || _selectedRole == null || isError;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      spacing: 40,
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
                          isActive: _selectedRole == UserRole.fisher,
                          onPressed: () =>
                              setState(() => _selectedRole = UserRole.fisher),
                        ),
                        const SizedBox(height: 20),
                        RoleButton(
                          title: "Buyer",
                          icon: "assets/icons/buyer.png",
                          isActive: _selectedRole == UserRole.buyer,
                          onPressed: () =>
                              setState(() => _selectedRole = UserRole.buyer),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Continue Button (Finalize selection and navigate)
                    CustomButton(
                      title: "Continue",
                      // Disable if role is unknown, or if BLoC is currently loading
                      disabled: buttonDisabled ||
                          _selectedRole == null ||
                          state is AuthLoading,
                      suffixIcon: CupertinoIcons.chevron_forward,
                      onPressed: () {
                        if (_selectedRole != null) {
                          // Login with specific demo user based on role
                          final userId = _selectedRole == UserRole.fisher
                              ? 'fisher-1' // Hardcoded for demo
                              : 'buyer-1'; // Hardcoded for demo

                          context.read<AuthCubit>().loginWithRole(
                            userId: userId,
                            role: _selectedRole!,
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
