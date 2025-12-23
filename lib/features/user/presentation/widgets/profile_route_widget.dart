import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/providers/auth_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/features/user/data/models/profile_route.dart';

class ProfileRouteWidget extends ConsumerWidget {
  const ProfileRouteWidget({super.key, required this.profileRoute, this.role});

  static const String routeName = '/user-profile';
  final ProfileRoute profileRoute;
  final UserRole? role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: InkWell(
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        onTap: profileRoute.route == null
            ? null
            : () async {
                if (profileRoute.route == 'logout') {
                  // Handle Logout
                  final sessionService = sl<SessionService>();
                  await sessionService.logout();

                  // Invalidate providers to trigger router refresh and redirection
                  ref.invalidate(isAuthenticatedProvider);
                  ref.invalidate(currentUserProvider);

                  // No need to manually push /login, the routerProvider redirect logic
                  // should detect the user is logged out and redirect them.
                  return;
                }

                final roleSlug = roleToString(role!);
                String path = '/user-profile/$roleSlug';
                path = '$path/${profileRoute.route}';
                if (profileRoute.subRoute != null) {
                  path = '$path/${profileRoute.subRoute}';
                  // For reviews route, append userId
                  if (profileRoute.subRoute == 'reviews') {
                    // Get userId from context - we'll need to pass it via ProfileRoute
                    if (profileRoute.userId != null) {
                      path = '$path/${profileRoute.userId}';
                    }
                  }
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
