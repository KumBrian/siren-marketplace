import '../entities/message.dart';

abstract class IMessageRepository {
  /// Send a new message
  Future<String> sendMessage(Message message);

  /// Get all messages in a conversation, ordered by timestamp
  Future<List<Message>> getMessagesByConversationId(String conversationId);

  /// Mark a message as read
  Future<void> markAsRead(String messageId);

  /// Get unread message count for a user in a conversation
  Future<int> getUnreadCount(String conversationId, String userId);

  /// Mark all messages in a conversation as read for a specific user
  Future<void> markAllAsRead(String conversationId, String userId);

  /// Delete a message
  Future<void> delete(String messageId);
}
