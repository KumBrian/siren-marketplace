import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar_tabs.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';
import 'package:siren_marketplace/features/user/presentation/screens/user_profile.dart';

import 'home_screen.dart';

class Fisher extends StatefulWidget {
  const Fisher({super.key});

  @override
  State<Fisher> createState() => _FisherState();
}

class _FisherState extends State<Fisher> with SingleTickerProviderStateMixin {
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
                FisherHome(),
                const Center(child: Text("Placeholder 2")),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return UserProfile(role: state.role.name);
                    }
                    return const Center(child: Text("Placeholder 4"));
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: BlocListener<UserBloc, UserState>(
                listenWhen: (previous, current) => current != previous,
                listener: (context, state) {
                  if (state is UserLoaded) {
                    final navCubit = context.read<BottomNavCubit>();
                    navCubit.reset();
                    _tabController.animateTo(1);
                  }
                },
                child: BlocBuilder<BottomNavCubit, int>(
                  builder: (context, state) {
                    if (context.read<UserBloc>().state is UserLoaded) {
                      return CustomNavBarWithTabs(
                        selectedIndex: state,
                        role:
                            (context.read<UserBloc>().state as UserLoaded).role,
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
