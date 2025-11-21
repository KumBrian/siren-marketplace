import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar_tabs.dart';
import 'package:siren_marketplace/features/user/presentation/screens/user_profile.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';

import 'home_screen.dart';
import 'orders_screen.dart';

class Buyer extends StatefulWidget {
  const Buyer({super.key});

  @override
  State<Buyer> createState() => _BuyerState();
}

class _BuyerState extends State<Buyer> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);

    // Keep Bloc and controller in sync both ways
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        context.read<BottomNavCubit>().changeIndex(_tabController.index);
      }
    });
  }

  Role _mapUserRoleToRole(UserRole role) {
    switch (role) {
      case UserRole.fisher:
        return Role.fisher;
      case UserRole.buyer:
        return Role.buyer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white100,
      body: BlocListener<BottomNavCubit, int>(
        listener: (context, state) {
          if (_tabController.index != state) {
            _tabController.animateTo(state);
          }
        },
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Center(child: Text("Placeholder 0")),
                BuyerHome(),
                const BuyerOrders(),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return UserProfile(role: state.currentRole.name);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: BlocListener<AuthCubit, AuthState>(
                listenWhen: (previous, current) => current != previous,
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    final navCubit = context.read<BottomNavCubit>();
                    navCubit.reset();
                    _tabController.animateTo(1);
                  }
                },
                child: BlocBuilder<BottomNavCubit, int>(
                  builder: (context, navState) {
                    final authState = context.watch<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      return CustomNavBarWithTabs(
                        selectedIndex: navState,
                        role: _mapUserRoleToRole(authState.currentRole),
                        onTabSelected: (value) {
                          context.read<BottomNavCubit>().changeIndex(value);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
