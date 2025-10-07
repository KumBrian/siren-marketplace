import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/components/custom_nav_bar_tabs.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/screens/buyer/buyer_home.dart';
import 'package:siren_marketplace/screens/buyer/buyer_orders.dart';

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
              children: const [
                Center(child: Text("Placeholder 0")),
                BuyerHome(),
                BuyerOrders(),
                Center(child: Text("Placeholder 3")),
              ],
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: BlocBuilder<BottomNavCubit, int>(
                builder: (context, state) {
                  return CustomNavBarWithTabs(
                    selectedIndex: state,
                    onTabSelected: (value) {
                      context.read<BottomNavCubit>().changeIndex(value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
