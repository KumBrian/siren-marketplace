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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<RoleCubit, Role>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 20,
                    children: [
                      Image(
                        image: AssetImage('assets/icons/siren_logo.png'),
                        width: 150,
                        height: 100,
                      ),

                      Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue,
                        ),
                      ),
                      Text(
                        "Please select your role to continue.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      RoleButton(
                        title: "Fisher",
                        icon: "assets/icons/fisher.png",
                        isActive:
                            context.watch<RoleCubit>().state == Role.fisher,
                        onPressed: () {
                          context.read<RoleCubit>().selectRole(Role.fisher);
                        },
                      ),
                      RoleButton(
                        title: "Buyer",
                        icon: "assets/icons/buyer.png",
                        isActive:
                            context.watch<RoleCubit>().state == Role.buyer,
                        onPressed: () {
                          context.read<RoleCubit>().selectRole(Role.buyer);
                        },
                      ),
                    ],
                  ),

                  CustomButton(
                    title: "Continue",
                    onPressed: () {
                      final role = context.read<RoleCubit>().state;
                      if (role != Role.unknown) {
                        // router redirect logic will take over
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
