import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/features/user/data/models/profile_route.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/profile_route_widget.dart';

final List<ProfileRoute> profileRoutes = [
  ProfileRoute(
    icon: CustomIcons.profile,
    title: "Account Info",
    route: "account-info",
  ),
  ProfileRoute(
    icon: CustomIcons.observation,
    title: "Observation Info",
    route: "observation-info",
  ),
  ProfileRoute(icon: CustomIcons.project, title: "Projects", route: "projects"),
  ProfileRoute(icon: CustomIcons.beach, title: "Beaches", route: "beaches"),
  ProfileRoute(icon: Icons.info_outline, title: "About Siren", route: "about"),
  ProfileRoute(icon: CustomIcons.logout, title: "Logout", route: "logout"),
];

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final Role userRole = roleFromString(role);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/icons/siren_logo.png",
          width: 100,
          height: 100,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                profileRoutes.length,
                (index) => ProfileRouteWidget(
                  profileRoute: profileRoutes[index],
                  role: userRole,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
