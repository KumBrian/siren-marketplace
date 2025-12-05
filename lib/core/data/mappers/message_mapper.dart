import '../../domain/entities/message.dart';
import '../models/message_model.dart';

class MessageMapper {
  static Message toEntity(MessageModel model) {
    return Message(
      id: model.id,
      conversationId: model.conversationId,
      senderId: model.senderId,
      receiverId: model.receiverId,
      content: model.content,
      timestamp: DateTime.parse(model.timestamp),
      isRead: model.isRead == 1,
      isSystemMessage: model.isSystemMessage == 1,
    );
  }

  static MessageModel toModel(Message entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      timestamp: entity.timestamp.toIso8601String(),
      isRead: entity.isRead ? 1 : 0,
      isSystemMessage: entity.isSystemMessage ? 1 : 0,
    );
  }
}
