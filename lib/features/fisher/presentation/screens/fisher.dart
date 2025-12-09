import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/providers/navigation_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/widgets/custom_nav_bar_tabs.dart';
import 'package:siren_marketplace/features/fisher/presentation/screens/catches_screen.dart';
import 'package:siren_marketplace/features/user/presentation/screens/user_profile.dart';

import 'home_screen.dart';

class Fisher extends ConsumerStatefulWidget {
  const Fisher({super.key});

  @override
  ConsumerState<Fisher> createState() => _FisherState();
}

class _FisherState extends ConsumerState<Fisher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);

    // Sync tab controller with Riverpod provider
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        ref.read(bottomNavIndexProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    // Sync provider changes back to tab controller
    ref.listen(bottomNavIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white100,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const Center(child: Text("Placeholder 0")),
              FisherHome(),
              CatchesScreen(),
              userAsync.when(
                data: (user) {
                  if (user != null) {
                    return UserProfile(role: user.currentRole.name);
                  }
                  return const Center(child: Text("No user loaded"));
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text("Error: $error")),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: userAsync.when(
              data: (user) {
                if (user != null) {
                  return CustomNavBarWithTabs(
                    selectedIndex: selectedIndex,
                    role: user.currentRole,
                    onTabSelected: (value) {
                      ref.read(bottomNavIndexProvider.notifier).state = value;
                    },
                  );
                }
                return const SizedBox();
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
