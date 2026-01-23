import 'dart:async';

import 'package:siren_marketplace/core/data/datasources/api/chat_api_data_source.dart';
import 'package:siren_marketplace/core/domain/repositories/i_chat_repository.dart';
import 'package:siren_marketplace/features/chat/domain/entities/conversation.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';
import 'package:siren_marketplace/core/domain/services/viewed_conversations_service.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/core/domain/repositories/i_conversation_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/domain/entities/conversation.dart'
    as core_entity;
import 'package:siren_marketplace/core/domain/enums/user_role.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatApiDataSource _api;
  final IViewedConversationsService? _viewedService;
  final ConnectivityService _connectivity;
  final IConversationRepository _localRepo;
  final IUserRepository _userRepo;
  final SessionService _sessionService;

  final Set<String> _pendingReadMessageIds = {};
  Timer? _batchTimer;

  ChatRepositoryImpl(
    this._api,
    this._viewedService,
    this._connectivity,
    this._localRepo,
    this._userRepo,
    this._sessionService,
  );

  @override
  Future<List<Conversation>> getMyConversations({String? productId}) async {
    // Check connectivity
    final isOffline =
        await _connectivity.checkConnectivity() == NetworkStatus.offline;

    if (isOffline) {
      return _getLocalConversations();
    }

    try {
      final conversations = await _api.getMyConversations(productId: productId);
      // Cache successful response
      await _cacheConversations(conversations);

      return _processViewedStatus(conversations);
    } catch (e) {
      return _getLocalConversations();
    }
  }

  Future<List<Conversation>> _getLocalConversations() async {
    final currentUser = await _sessionService.getCurrentUser();
    if (currentUser == null) return [];

    final localConvs = await _localRepo.getConversationsForUser(currentUser.id);
    final featureConvs = <Conversation>[];

    for (final coreConv in localConvs) {
      // Reconstruct users
      final buyer = await _userRepo.getById(coreConv.buyerId);
      final fisher = await _userRepo.getById(coreConv.fisherId);

      if (buyer != null && fisher != null) {
        // Determine unread count
        final isBuyer = currentUser.id == buyer.id;
        final unread = isBuyer
            ? coreConv.unreadCountForBuyer
            : coreConv.unreadCountForFisher;

        featureConvs.add(
          Conversation(
            id: coreConv.id,
            sourceAccount: buyer,
            targetAccount: fisher,
            lastMessage: coreConv.lastMessage.isNotEmpty
                ? Message(
                    id: 'local_${coreConv.id}', // Placeholder ID
                    content: coreConv.lastMessage,
                    createdAt: coreConv.lastMessageTime,
                    sender: isBuyer
                        ? fisher
                        : buyer, // Assume counterparty sent it (safer default)
                    receiver: isBuyer ? buyer : fisher,
                  )
                : null,
            unreadCount: unread,
            createdAt: coreConv.lastMessageTime, // Approx
            updatedAt: coreConv.lastMessageTime,
          ),
        );
      }
    }
    return _processViewedStatus(featureConvs);
  }

  Future<void> _cacheConversations(List<Conversation> conversations) async {
    for (final conv in conversations) {
      // Map Feature -> Core
      String? buyerId;
      String? fisherId;
      int unreadForBuyer = 0;
      int unreadForFisher = 0;

      // Determine roles
      if (conv.sourceAccount.currentRole == UserRole.buyer) {
        buyerId = conv.sourceAccount.id;
      } else {
        fisherId = conv.sourceAccount.id;
      }

      if (conv.targetAccount.currentRole == UserRole.buyer) {
        buyerId = conv.targetAccount.id;
      } else {
        fisherId = conv.targetAccount.id;
      }

      // If roles unclear, skip caching or make assumptions
      if (buyerId == null || fisherId == null) continue;

      // Map unread counts (best effort)
      // We only know unread count for current user
      // We don't overwrite the OTHER user's unread count if we can avoid it,
      // but simple update overwrites.
      final currentUser = await _sessionService.getCurrentUser();
      if (currentUser != null) {
        if (currentUser.id == buyerId) {
          unreadForBuyer = conv.unreadCount;
        } else {
          unreadForFisher = conv.unreadCount;
        }
      }

      final coreConv = core_entity.Conversation(
        id: conv.id,
        buyerId: buyerId,
        fisherId: fisherId,
        lastMessage: conv.lastMessage?.content ?? '',
        lastMessageTime: conv.lastMessage?.createdAt ?? conv.updatedAt,
        unreadCountForBuyer: unreadForBuyer,
        unreadCountForFisher: unreadForFisher,
      );

      await _localRepo.update(coreConv);
    }
  }

  List<Conversation> _processViewedStatus(List<Conversation> conversations) {
    if (_viewedService == null) return conversations;

    return conversations.map((c) {
      if (c.lastMessage == null) return c;

      final isViewed = _viewedService.isViewed(c.id, c.lastMessage!.createdAt);
      if (isViewed) {
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
    String? productId,
  }) async {
    final body = <String, dynamic>{
      'targetAccountId': int.parse(targetAccountId),
    };
    if (productId != null) {
      body['productId'] = int.parse(productId);
    }
    return _api.openConversation(body);
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

    _pendingReadMessageIds.clear();

    // API Call disabled as per user request
    // API Call disabled as per user request
  }
}
