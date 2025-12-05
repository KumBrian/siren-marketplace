import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String buyerId;
  final String fisherId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCountForBuyer;
  final int unreadCountForFisher;

  const Conversation({
    required this.id,
    required this.buyerId,
    required this.fisherId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCountForBuyer = 0,
    this.unreadCountForFisher = 0,
  });

  // Business Logic
  String getOtherParticipantId(String currentUserId) {
    if (currentUserId == buyerId) return fisherId;
    if (currentUserId == fisherId) return buyerId;
    throw ArgumentError('User is not part of this conversation');
  }

  int getUnreadCountFor(String userId) {
    if (userId == buyerId) return unreadCountForBuyer;
    if (userId == fisherId) return unreadCountForFisher;
    return 0;
  }

  bool hasUnreadMessagesFor(String userId) {
    return getUnreadCountFor(userId) > 0;
  }

  // Generate conversation ID from participant IDs
  static String generateId(String buyerId, String fisherId) {
    // Always use the same order to ensure consistency
    final ids = [buyerId, fisherId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Domain Actions
  Conversation updateLastMessage(String message, DateTime timestamp) {
    return copyWith(lastMessage: message, lastMessageTime: timestamp);
  }

  Conversation incrementUnreadFor(String userId) {
    if (userId == buyerId) {
      return copyWith(unreadCountForBuyer: unreadCountForBuyer + 1);
    } else if (userId == fisherId) {
      return copyWith(unreadCountForFisher: unreadCountForFisher + 1);
    }
    return this;
  }

  Conversation resetUnreadFor(String userId) {
    if (userId == buyerId) {
      return copyWith(unreadCountForBuyer: 0);
    } else if (userId == fisherId) {
      return copyWith(unreadCountForFisher: 0);
    }
    return this;
  }

  Conversation copyWith({
    String? id,
    String? buyerId,
    String? fisherId,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCountForBuyer,
    int? unreadCountForFisher,
  }) {
    return Conversation(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      fisherId: fisherId ?? this.fisherId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCountForBuyer: unreadCountForBuyer ?? this.unreadCountForBuyer,
      unreadCountForFisher: unreadCountForFisher ?? this.unreadCountForFisher,
    );
  }

  @override
  List<Object?> get props => [
    id,
    buyerId,
    fisherId,
    lastMessage,
    lastMessageTime,
    unreadCountForBuyer,
    unreadCountForFisher,
  ];
}
