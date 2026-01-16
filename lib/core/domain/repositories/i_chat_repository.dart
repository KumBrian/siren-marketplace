import 'package:siren_marketplace/features/chat/domain/entities/conversation.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';

abstract class IChatRepository {
  Future<List<Conversation>> getMyConversations({String? productId});
  Future<Conversation> startConversation({
    required String targetAccountId,
    String? productId,
  });
  Future<List<Message>> getMessages({required String conversationId});
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Mark a list of messages as read (API side)
  Future<void> markMessagesAsRead(List<String> messageIds);

  /// Mark a conversation as viewed locally
  Future<void> markConversationAsRead(String conversationId);
}
