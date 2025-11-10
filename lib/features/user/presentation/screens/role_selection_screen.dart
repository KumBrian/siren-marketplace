import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/role_button.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  // Local state to hold the currently selected role for UI
  Role _selectedRole = Role.unknown;

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
          child: BlocConsumer<UserBloc, UserState>(
            listener: (context, state) {
              // Initialize selection on first load
              if (state is UserLoaded && _selectedRole == Role.unknown) {
                setState(() {
                  _selectedRole = state.role;
                });
              }

              // If there's an error, reset selection on the next frame (safe)
              if (state is UserError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedRole = Role.unknown;
                  });
                });
              }

              if (state is UserLoaded) {
                // safe navigation after state settled
                if (state.role == Role.buyer) {
                  // use addPostFrame to be extra safe
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.go('/buyer');
                  });
                } else if (state.role == Role.fisher) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.go('/fisher');
                  });
                }
              }
            },
            builder: (context, state) {
              final bool isLoading = state is UserLoading;
              final bool isError = state is UserError;

              // Disable button if loading or unknown selection
              final buttonDisabled =
                  isLoading || _selectedRole == Role.unknown || isError;

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
                          isActive: _selectedRole == Role.fisher,
                          onPressed: () =>
                              setState(() => _selectedRole = Role.fisher),
                        ),
                        const SizedBox(height: 20),
                        RoleButton(
                          title: "Buyer",
                          icon: "assets/icons/buyer.png",
                          isActive: _selectedRole == Role.buyer,
                          onPressed: () =>
                              setState(() => _selectedRole = Role.buyer),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Continue Button (Finalize selection and navigate)
                    CustomButton(
                      title: "Continue",
                      // Disable if role is unknown, or if BLoC is currently loading
                      disabled:
                          buttonDisabled ||
                          _selectedRole == Role.unknown ||
                          state is UserLoading,
                      suffixIcon: CupertinoIcons.chevron_forward,
                      onPressed: () {
                        // 1. Emit the Finalize event to load the user profile
                        context.read<UserBloc>().add(
                          FinalizeRoleSelection(_selectedRole),
                        );
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
