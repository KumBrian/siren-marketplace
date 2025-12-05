import 'package:siren_marketplace/core/data/models/message_model.dart';

abstract class IMessageDataSource {
  /// Send a new message
  Future<String> create(MessageModel message);

  /// Get all messages in a conversation, ordered by timestamp
  Future<List<MessageModel>> getByConversationId(String conversationId);

  /// Mark a message as read
  Future<void> markAsRead(String messageId);

  /// Get unread message count for a user in a conversation
  Future<int> getUnreadCount(String conversationId, String userId);

  /// Mark all messages in a conversation as read for a specific user
  Future<void> markAllAsRead(String conversationId, String userId);

  /// Delete a message
  Future<void> delete(String messageId);
}
