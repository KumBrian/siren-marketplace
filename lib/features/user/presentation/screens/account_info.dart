import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/user/data/models/profile_route.dart';
import 'package:siren_marketplace/features/user/logic/notifications_cubit/notifications_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/profile_route_widget.dart';

List<ProfileRoute> profileRoutes = [
  ProfileRoute(
    title: "Personal Information",
    route: "account-info",
    subRoute: "personal-information",
  ),
  ProfileRoute(
    title: "Reviews & Ratings",
    route: "account-info",
    subRoute: "reviews",
  ),
  ProfileRoute(
    title: "Notifications",
    trailing: SizedBox(
      height: 24,
      child: Transform.scale(
        scale: 0.7,
        child: BlocBuilder<NotificationsCubit, bool>(
          builder: (context, notificationState) {
            return Switch.adaptive(
              value: notificationState,
              onChanged: (v) {
                context.read<NotificationsCubit>().toggle();
              },
              activeTrackColor: AppColors.textBlue,
            );
          },
        ),
      ),
    ),
  ),
];

class AccountInfo extends StatelessWidget {
  const AccountInfo({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Info",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) {
            final user = userState.user;
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          user!.avatarUrl,
                          fit: BoxFit.cover,
                          height: 150,
                          width: 150,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                "assets/images/user-profile.png",
                                fit: BoxFit.cover,
                                height: 150,
                                width: 150,
                              ),
                        ),
                      ),

                      SectionHeader(user.name.capitalize(), fontSize: 22),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            roleToString(user.role).capitalize(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/svgs/medallion.svg",
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: List.generate(
                        profileRoutes.length,
                        (index) => ProfileRouteWidget(
                          profileRoute: profileRoutes[index],
                          role: user.role,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
