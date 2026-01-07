import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/data/datasources/api/chat_api_data_source.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/repositories/i_chat_repository.dart';
import 'package:siren_marketplace/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:siren_marketplace/features/chat/domain/entities/conversation.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';
import 'package:siren_marketplace/core/domain/services/viewed_conversations_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/domain/repositories/i_conversation_repository.dart';
import '../../../../core/domain/repositories/i_user_repository.dart';
import '../../../../core/domain/services/session_service.dart';

// Repository Provider
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(
    sl<ChatApiDataSource>(),
    sl<IViewedConversationsService>(),
    sl<ConnectivityService>(),
    sl<IConversationRepository>(), // Helper Core Repo (Local)
    sl<IUserRepository>(),
    sl<
      SessionService
    >(), // Ensure SessionService is registered in SL or use provider
  );
});

// Conversations List Provider
final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((
  ref,
) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMyConversations();
});

// Messages List Provider (Family)
final messagesProvider = FutureProvider.autoDispose
    .family<List<Message>, String>((ref, conversationId) async {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.getMessages(conversationId: conversationId);
    });

// Chat Controller for Actions
final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider), ref);
});

class ChatController {
  final IChatRepository _repository;
  final Ref _ref;

  ChatController(this._repository, this._ref);

  Future<void> sendMessage(String conversationId, String content) async {
    await _repository.sendMessage(
      conversationId: conversationId,
      content: content,
    );
    // Invalidate messages to refresh list
    _ref.invalidate(messagesProvider(conversationId));
    // Also invalidate conversations to update last message
    _ref.invalidate(conversationsProvider);
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    await _repository.markMessagesAsRead(messageIds);
    // Optimistic update or invalidation could go here if needed,
    // but usually read receipts are subtle updates.
    // For now, we rely on the next fetch or socket update (future) to show 'read'.
  }

  Future<String> startConversation(String targetAccountId) async {
    final conversation = await _repository.startConversation(
      targetAccountId: targetAccountId,
    );
    _ref.invalidate(conversationsProvider);
    return conversation.id;
  }

  Future<void> markConversationAsRead(String conversationId) async {
    await _repository.markConversationAsRead(conversationId);
    // Invalidate conversation list to update unread badge locally immediately
    _ref.invalidate(conversationsProvider);
  }
}
