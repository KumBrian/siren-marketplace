import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';

class Conversation extends Equatable {
  final String id;
  final User sourceAccount;
  final User targetAccount;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.sourceAccount,
    required this.targetAccount,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  User getOtherParticipant(User currentUser) {
    bool isSourceMe = sourceAccount.id == currentUser.id;
    // Fallback if IDs mismatch (e.g. Int ID vs UUID)
    if (!isSourceMe && sourceAccount.name == currentUser.name) {
      isSourceMe = true;
    }

    if (isSourceMe) {
      return targetAccount;
    }
    return sourceAccount;
  }

  bool hasUnreadMessagesFor(String userId) {
    // Assuming unreadCount is personalized for the fetching user
    return unreadCount > 0;
  }

  @override
  List<Object?> get props => [
    id,
    sourceAccount,
    targetAccount,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
  ];
}
