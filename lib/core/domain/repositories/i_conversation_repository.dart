import '../entities/conversation.dart';

abstract class IConversationRepository {
  /// Get existing conversation or create a new one between two users
  Future<Conversation> getOrCreateConversation(String buyerId, String fisherId);

  /// Get a conversation by ID
  Future<Conversation?> getById(String conversationId);

  /// Get all conversations for a user (as buyer or fisher)
  Future<List<Conversation>> getConversationsForUser(String userId);

  /// Update the last message in a conversation
  Future<void> updateLastMessage(
    String conversationId,
    String message,
    DateTime timestamp,
  );

  /// Increment unread count for a specific user
  Future<void> incrementUnreadCount(String conversationId, String forUserId);

  /// Reset unread count for a specific user
  Future<void> resetUnreadCount(String conversationId, String forUserId);

  /// Update conversation
  Future<void> update(Conversation conversation);

  /// Delete a conversation
  Future<void> delete(String conversationId);
}
