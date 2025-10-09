import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/role_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/role_button.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  Role? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<UserRoleCubit, Role>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/siren_logo.png',
                        width: 150,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Please select your role to continue.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RoleButton(
                        title: "Fisher",
                        icon: "assets/icons/fisher.png",
                        isActive: selectedRole == Role.fisher,
                        onPressed: () {
                          setState(() => selectedRole = Role.fisher);
                        },
                      ),
                      const SizedBox(height: 20),
                      RoleButton(
                        title: "Buyer",
                        icon: "assets/icons/buyer.png",
                        isActive: selectedRole == Role.buyer,
                        onPressed: () {
                          setState(() => selectedRole = Role.buyer);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    title: "Continue",
                    disabled: selectedRole == null,

                    suffixIcon: CupertinoIcons.chevron_forward,
                    onPressed: () {
                      if (selectedRole != null &&
                          selectedRole != Role.unknown) {
                        // router redirect logic will take over
                        context.read<UserRoleCubit>().setRole(selectedRole!);
                        context.go('/');
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
