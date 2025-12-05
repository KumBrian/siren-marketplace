import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String timestamp; // Stored as ISO8601 string
  final int isRead; // SQLite boolean (0 or 1)
  final int isSystemMessage; // SQLite boolean (0 or 1)

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.isSystemMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp,
      'is_read': isRead,
      'is_system_message': isSystemMessage,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as String,
      isRead: map['is_read'] as int,
      isSystemMessage: map['is_system_message'] as int,
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
