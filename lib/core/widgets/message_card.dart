import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

import 'error_handling_circle_avatar.dart';

class MessageCard extends StatelessWidget {
  final String messageId;
  final String name;
  final String time;
  final String message;
  final int unreadCount;
  final String avatarPath;
  final VoidCallback onPressed;

  const MessageCard({
    super.key,
    required this.messageId,
    required this.name,
    required this.time,
    required this.message,
    required this.unreadCount,
    required this.onPressed,
    this.avatarPath = "assets/images/user-profile.png",
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.push("/fisher/chat");
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorHandlingCircleAvatar(avatarUrl: avatarPath),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerRow(),
                    const SizedBox(height: 4),
                    _messageRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top row: name + time
  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _text(name, AppColors.textBlue, fontWeight: FontWeight.w500),
        _text(time, AppColors.blue800, fontSize: 12),
      ],
    );
  }

  /// Bottom row: message + unread badge
  Widget _messageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _text(message, AppColors.textGray, fontSize: 14)),
        if (unreadCount > 0) _unreadBadge(unreadCount),
      ],
    );
  }

  /// Reusable text helper
  Widget _text(
    String text,
    Color color, {
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Circle badge for unread messages
  Widget _unreadBadge(int count) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blue700,
      ),
      child: Text(
        "$count",
        style: TextStyle(fontSize: 12, color: AppColors.textWhite),
      ),
    );
  }
}
