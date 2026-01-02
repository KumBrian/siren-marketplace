import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/error_handling_circle_avatar.dart';
import '../../../../core/domain/entities/user.dart';
import '../../domain/entities/conversation.dart';

class ConversationCard extends ConsumerWidget {
  final Conversation conversation;
  final User currentUser;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUser,
    required this.onTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(timestamp);
    } else {
      // Older - show date
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the other participant
    final otherUser = conversation.getOtherParticipant(currentUser);
    final hasUnread = conversation.hasUnreadMessagesFor(currentUser.id);
    final unreadCount = conversation.unreadCount;
    final lastMsg = conversation.lastMessage;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            ErrorHandlingCircleAvatar(
              avatarUrl:
                  otherUser.avatarUrl ?? 'assets/images/user-profile.png',
              radius: 24,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name and rating
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                otherUser.name,
                                style: TextStyle(
                                  color: hasUnread
                                      ? AppColors.textBlue
                                      : AppColors.textGray,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (otherUser.hasRatings) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: AppColors.shellOrange,
                                size: 12,
                              ),
                              Text(
                                otherUser.rating.value.toStringAsFixed(1),
                                style: TextStyle(
                                  color: hasUnread
                                      ? AppColors.textBlue
                                      : AppColors.textGray,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.w300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Timestamp
                      Text(
                        _formatTimestamp(conversation.updatedAt),
                        style: TextStyle(
                          color: hasUnread
                              ? AppColors.textBlue
                              : AppColors.textGray,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w300,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Last message and unread count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg?.content ?? 'No messages yet',
                          style: TextStyle(
                            color: hasUnread
                                ? AppColors.textBlue
                                : AppColors.textGray,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w300,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
