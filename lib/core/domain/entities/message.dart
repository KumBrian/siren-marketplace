import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSystemMessage;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSystemMessage = false,
  });

  // Business Logic
  bool isSentBy(String userId) => senderId == userId;

  bool isReceivedBy(String userId) => receiverId == userId;

  // Domain Actions
  Message markAsRead() {
    if (isRead) return this;
    return copyWith(isRead: true);
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSystemMessage,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    content,
    timestamp,
    isRead,
    isSystemMessage,
  ];
}
