import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/providers/notification_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';
import 'package:siren_marketplace/core/utils/custom_dialogs.dart';
import 'package:siren_marketplace/features/user/data/models/profile_route.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/profile_route_widget.dart';

List<ProfileRoute> getProfileRoutes(
  BuildContext context,
  WidgetRef ref,
  String? userId,
) => [
  ProfileRoute(
    title: "Personal Information",
    route: "account-info",
    subRoute: "personal-information",
  ),
  ProfileRoute(
    title: "Reviews & Ratings",
    route: "account-info",
    subRoute: "reviews",
    userId: userId,
  ),
  ProfileRoute(
    title: "Notifications",
    trailing: SizedBox(
      height: 24,
      child: Transform.scale(
        scale: 0.7,
        child: Consumer(
          builder: (context, ref, _) {
            final notificationsEnabled = ref.watch(
              notificationSettingsProvider,
            );
            return Switch.adaptive(
              value: notificationsEnabled,
              onChanged: (v) async {
                final notifier = ref.read(
                  notificationSettingsProvider.notifier,
                );
                final success = await notifier.toggleNotifications(v);

                if (!success && v) {
                  // Show permission denied message
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => const ErrorDialog(
                        title: "Permission Denied",
                        message:
                            'Notification permission denied. Please enable in device settings.',
                      ),
                    );
                  }
                }
              },
              activeTrackColor: AppColors.textBlue,
            );
          },
        ),
      ),
    ),
  ),
  ProfileRoute(
    title: "Test Notification",
    onTap: () async {
      final notifier = ref.read(notificationSettingsProvider.notifier);
      final success = await notifier.sendTestNotification();

      if (context.mounted) {
        if (success) {
          showActionSuccessDialog(
            context,
            message: 'Test notification sent successfully!',
            autoCloseSeconds: 3,
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => const ErrorDialog(
              title: "Notification Failed",
              message: 'Failed to send test notification.',
            ),
          );
        }
      }
    },
    trailing: const Icon(Icons.send, size: 20, color: AppColors.textBlue),
  ),
];

class AccountInfo extends ConsumerWidget {
  const AccountInfo({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: PageTitle(title: "Account Info"),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found"));
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.network(
                        user.avatarUrl ?? "",
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
                          roleToString(user.currentRole).capitalize(),
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
                      getProfileRoutes(context, ref, user.id).length,
                      (index) => ProfileRouteWidget(
                        profileRoute: getProfileRoutes(
                          context,
                          ref,
                          user.id,
                        )[index],
                        role: user.currentRole,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
