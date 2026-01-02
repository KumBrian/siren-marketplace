import 'dart:async';

import 'package:siren_marketplace/core/data/datasources/api/chat_api_data_source.dart';
import 'package:siren_marketplace/core/domain/repositories/i_chat_repository.dart';
import 'package:siren_marketplace/features/chat/domain/entities/conversation.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';

import 'package:siren_marketplace/core/domain/services/viewed_conversations_service.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatApiDataSource _api;
  final IViewedConversationsService? _viewedService;
  final Set<String> _pendingReadMessageIds = {};
  Timer? _batchTimer;

  ChatRepositoryImpl(this._api, [this._viewedService]);

  @override
  Future<List<Conversation>> getMyConversations() async {
    final conversations = await _api.getMyConversations();
    if (_viewedService == null) return conversations;

    return conversations.map((c) {
      if (c.lastMessage == null) return c;

      final isViewed = _viewedService.isViewed(c.id, c.lastMessage!.createdAt);
      if (isViewed) {
        // Return a copy with 0 unread count if viewed locally
        return Conversation(
          id: c.id,
          sourceAccount: c.sourceAccount,
          targetAccount: c.targetAccount,
          lastMessage: c.lastMessage,
          unreadCount: 0,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        );
      }
      return c;
    }).toList();
  }

  @override
  Future<Conversation> startConversation({
    required String targetAccountId,
  }) async {
    return _api.openConversation({
      'targetAccountId': int.parse(targetAccountId),
    });
  }

  @override
  Future<List<Message>> getMessages({required String conversationId}) async {
    return _api.getMessages(conversationId);
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    return _api.sendMessage({
      'conversationId': int.parse(conversationId),
      'content': content,
    });
  }

  @override
  Future<void> markMessagesAsRead(List<String> messageIds) async {
    // For now, we only mark as viewed locally when this is called.
    // However, the controller calls this with message IDs.
    // We ironically need the Conversation ID to mark it as viewed key-value.
    // But this method receives message IDs.
    //
    // To support local "mark conversation as read", we should probably change the interface
    // or infer the conversation ID. But we can't easily infer it from message IDs here without fetching.
    //
    // Actually, ChatController.markMessagesAsRead is called when messages are seen.
    // But we want to mark the CONVERSATION as viewed.
    //
    // Let's assume the controller will call a new method or we update this one.
    // But `IChatRepository` defines `markMessagesAsRead(List<String> messageIds)`.
    //
    // Ideally, the ChatController should call `markConversationAsViewed(conversationId)`.
    // But the current flow is detecting messages visibility.
    //
    // Temporary Hack:
    // If we want to disable the API call, we just do nothing here or keep the log.
    // The actual "mark as read" logic for local state needs to happen when entering the chat
    // or receiving messages.
    //
    // See ChatController.markMessageAsRead. It adds to list.
    //
    // We need a method `markConversationAsRead(String conversationId)` in the repo/controller.
    _pendingReadMessageIds.addAll(messageIds);
    if (_batchTimer?.isActive ?? false) return;
    _batchTimer = Timer(const Duration(seconds: 2), _flushReadMessages);
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    if (_viewedService != null) {
      await _viewedService.markAsViewed(conversationId, DateTime.now());
    }
  }

  Future<void> _flushReadMessages() async {
    if (_pendingReadMessageIds.isEmpty) return;

    final idsToSend = _pendingReadMessageIds.toList();
    _pendingReadMessageIds.clear();

    // API Call disabled as per user request
    print(
      'DEBUG: Skipped flushing ${idsToSend.length} read messages to API (disabled)',
    );
  }
}
