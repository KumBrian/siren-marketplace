import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/role_cubit.dart';
import 'package:siren_marketplace/constants/types.dart';

import 'buyer/buyer_home.dart';
import 'fisher/fisher_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserRoleCubit, Role>(
        builder: (context, state) {
          return state == Role.fisher ? const FisherHome() : const BuyerHome();
        },
      ),
    );
  }
}
