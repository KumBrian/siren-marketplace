import '../../domain/entities/message.dart';
import '../../domain/repositories/i_message_repository.dart';
import '../datasources/interfaces/i_message_datasource.dart';
import '../mappers/message_mapper.dart';

class MessageRepositoryImpl implements IMessageRepository {
  final IMessageDataSource dataSource;

  MessageRepositoryImpl({required this.dataSource});

  @override
  Future<String> sendMessage(Message message) async {
    final model = MessageMapper.toModel(message);
    return await dataSource.create(model);
  }

  @override
  Future<List<Message>> getMessagesByConversationId(
    String conversationId,
  ) async {
    final models = await dataSource.getByConversationId(conversationId);
    return models.map((m) => MessageMapper.toEntity(m)).toList();
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await dataSource.markAsRead(messageId);
  }

  @override
  Future<int> getUnreadCount(String conversationId, String userId) async {
    return await dataSource.getUnreadCount(conversationId, userId);
  }

  @override
  Future<void> markAllAsRead(String conversationId, String userId) async {
    await dataSource.markAllAsRead(conversationId, userId);
  }

  @override
  Future<void> delete(String messageId) async {
    await dataSource.delete(messageId);
  }
}
