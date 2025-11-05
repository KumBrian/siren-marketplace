import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/user/data/models/profile_route.dart';

class ProfileRouteWidget extends StatelessWidget {
  const ProfileRouteWidget({super.key, required this.profileRoute, this.role});

  static const String routeName = '/user-profile';
  final ProfileRoute profileRoute;
  final Role? role;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        onTap: profileRoute.route == null
            ? null
            : () {
                final roleSlug = roleToString(role!);
                String path = '/user-profile/$roleSlug';
                path = '$path/${profileRoute.route}';
                if (profileRoute.subRoute != null) {
                  path = '$path/${profileRoute.subRoute}';
                }

                context.push(path);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.gray200, width: 1),
            ),
          ),
          child: Row(
            children: [
              if (profileRoute.icon != null) ...[
                Icon(profileRoute.icon, color: AppColors.textBlue),
                const SizedBox(width: 32),
              ],

              Text(
                profileRoute.title,
                style: TextStyle(
                  color: AppColors.textBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (profileRoute.trailing != null) ...[profileRoute.trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
