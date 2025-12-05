import '../../domain/entities/conversation.dart';
import '../../domain/repositories/i_conversation_repository.dart';
import '../datasources/interfaces/i_conversation_datasource.dart';
import '../mappers/conversation_mapper.dart';

class ConversationRepositoryImpl implements IConversationRepository {
  final IConversationDataSource dataSource;

  ConversationRepositoryImpl({required this.dataSource});

  @override
  Future<Conversation> getOrCreateConversation(
    String buyerId,
    String fisherId,
  ) async {
    final model = await dataSource.getOrCreate(buyerId, fisherId);
    return ConversationMapper.toEntity(model);
  }

  @override
  Future<Conversation?> getById(String conversationId) async {
    final model = await dataSource.getById(conversationId);
    return model != null ? ConversationMapper.toEntity(model) : null;
  }

  @override
  Future<List<Conversation>> getConversationsForUser(String userId) async {
    final models = await dataSource.getByUserId(userId);
    return models.map((m) => ConversationMapper.toEntity(m)).toList();
  }

  @override
  Future<void> updateLastMessage(
    String conversationId,
    String message,
    DateTime timestamp,
  ) async {
    final conversation = await getById(conversationId);
    if (conversation == null) return;

    final updated = conversation.updateLastMessage(message, timestamp);
    await update(updated);
  }

  @override
  Future<void> incrementUnreadCount(
    String conversationId,
    String forUserId,
  ) async {
    final conversation = await getById(conversationId);
    if (conversation == null) return;

    final updated = conversation.incrementUnreadFor(forUserId);
    await update(updated);
  }

  @override
  Future<void> resetUnreadCount(String conversationId, String forUserId) async {
    final conversation = await getById(conversationId);
    if (conversation == null) return;

    final updated = conversation.resetUnreadFor(forUserId);
    await update(updated);
  }

  @override
  Future<void> update(Conversation conversation) async {
    final model = ConversationMapper.toModel(conversation);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String conversationId) async {
    await dataSource.delete(conversationId);
  }
}
