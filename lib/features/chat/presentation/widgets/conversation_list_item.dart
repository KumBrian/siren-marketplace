// import 'package:flutter/material.dart';
// import 'package:siren_marketplace/core/constants/app_colors.dart';
// import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
//
// class ConversationListItem extends StatelessWidget {
//   final Conversation conversation;
//   final String currentUserId;
//   final VoidCallback onTap;
//
//   const ConversationListItem({
//     super.key,
//     required this.conversation,
//     required this.currentUserId,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine the other participant
//     final otherParticipantId = conversation.participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => 'Unknown',
//     );
//
//     // In a real app, we would look up the user details for otherParticipantId
//     // For now, we'll just show the ID or a placeholder
//     final otherParticipantName = "User $otherParticipantId";
//     final lastMessage = conversation.lastMessage?.content ?? "No messages yet";
//     final time = conversation.lastMessage?.timestamp.toString() ?? "";
//
//     return ListTile(
//       leading: const ErrorHandlingCircleAvatar(
//         avatarUrl: "assets/images/user-profile.png",
//       ),
//       title: Text(
//         otherParticipantName,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: AppColors.textBlue,
//         ),
//       ),
//       subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
//       trailing: Text(
//         time, // Format this properly in a real app
//         style: const TextStyle(fontSize: 12, color: Colors.grey),
//       ),
//       onTap: onTap,
//     );
//   }
// }
