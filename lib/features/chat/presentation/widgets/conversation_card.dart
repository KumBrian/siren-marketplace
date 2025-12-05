import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/domain/entities/conversation.dart';
import '../../../../core/domain/entities/user.dart';
import '../../../../core/providers/user_providers.dart';
import '../../../../core/widgets/error_handling_circle_avatar.dart';

class ConversationCard extends ConsumerWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
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
    // Get the other participant's ID
    final otherUserId = conversation.getOtherParticipantId(currentUserId);
    final userAsync = ref.watch(userProvider(otherUserId));

    final hasUnread = conversation.hasUnreadMessagesFor(currentUserId);
    final unreadCount = conversation.getUnreadCountFor(currentUserId);

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
            userAsync.when(
              data: (user) => ErrorHandlingCircleAvatar(
                avatarUrl: user?.avatarUrl ?? 'assets/images/user-profile.png',
                radius: 24,
              ),
              loading: () => const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.gray200,
              ),
              error: (_, __) => const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.gray200,
                child: Icon(Icons.person, color: AppColors.textGray),
              ),
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
                        child: userAsync.when(
                          data: (user) => Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Loading...',
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
                              if (user != null && user.hasRatings) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  color: AppColors.shellOrange,
                                  size: 12,
                                ),
                                Text(
                                  user.rating.value.toStringAsFixed(1),
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
                          loading: () => const Text(
                            'Loading...',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                          error: (_, __) => const Text(
                            'Error',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Timestamp
                      Text(
                        _formatTimestamp(conversation.lastMessageTime),
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
                          conversation.lastMessage.isEmpty
                              ? 'No messages yet'
                              : conversation.lastMessage,
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
