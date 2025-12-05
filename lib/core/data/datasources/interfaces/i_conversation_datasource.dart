import 'package:siren_marketplace/core/data/models/conversation_model.dart';

abstract class IConversationDataSource {
  /// Get existing conversation or create a new one between two users
  Future<ConversationModel> getOrCreate(String buyerId, String fisherId);

  /// Get a conversation by ID
  Future<ConversationModel?> getById(String conversationId);

  /// Get all conversations for a user (as buyer or fisher)
  Future<List<ConversationModel>> getByUserId(String userId);

  /// Update a conversation
  Future<void> update(ConversationModel conversation);

  /// Delete a conversation
  Future<void> delete(String conversationId);
}
