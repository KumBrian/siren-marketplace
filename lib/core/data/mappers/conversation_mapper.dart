import '../../domain/entities/conversation.dart';
import '../models/conversation_model.dart';

class ConversationMapper {
  static Conversation toEntity(ConversationModel model) {
    return Conversation(
      id: model.id,
      buyerId: model.buyerId,
      fisherId: model.fisherId,
      lastMessage: model.lastMessage,
      lastMessageTime: DateTime.parse(model.lastMessageTime),
      unreadCountForBuyer: model.unreadCountForBuyer,
      unreadCountForFisher: model.unreadCountForFisher,
    );
  }

  static ConversationModel toModel(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      buyerId: entity.buyerId,
      fisherId: entity.fisherId,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime.toIso8601String(),
      unreadCountForBuyer: entity.unreadCountForBuyer,
      unreadCountForFisher: entity.unreadCountForFisher,
    );
  }
}
