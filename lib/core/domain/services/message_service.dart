import 'package:uuid/uuid.dart';

import '../entities/message.dart';
import '../entities/order.dart';
import '../enums/user_role.dart';
import '../repositories/i_conversation_repository.dart';
import '../repositories/i_message_repository.dart';
import '../repositories/i_user_repository.dart';

class MessageService {
  final IMessageRepository _messageRepository;
  final IConversationRepository _conversationRepository;
  final IUserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  MessageService({
    required IMessageRepository messageRepository,
    required IConversationRepository conversationRepository,
    required IUserRepository userRepository,
  }) : _messageRepository = messageRepository,
       _conversationRepository = conversationRepository,
       _userRepository = userRepository;

  /// Send a message from one user to another
  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    bool isSystemMessage = false,
  }) async {
    // Determine buyer and fisher IDs
    final sender = await _userRepository.getById(senderId);
    final receiver = await _userRepository.getById(receiverId);

    if (sender == null || receiver == null) {
      throw Exception('Sender or receiver not found');
    }

    // Determine buyer and fisher based on roles
    String buyerId;
    String fisherId;

    if (sender.currentRole == UserRole.buyer &&
        receiver.currentRole == UserRole.fisher) {
      buyerId = senderId;
      fisherId = receiverId;
    } else if (sender.currentRole == UserRole.fisher &&
        receiver.currentRole == UserRole.buyer) {
      fisherId = senderId;
      buyerId = receiverId;
    } else {
      throw Exception('Messages can only be sent between buyers and fishers');
    }

    // Get or create conversation
    final conversation = await _conversationRepository.getOrCreateConversation(
      buyerId,
      fisherId,
    );

    // Create message
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversation.id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isSystemMessage: isSystemMessage,
    );

    // Send message
    await _messageRepository.sendMessage(message);

    // Update conversation last message
    await _conversationRepository.updateLastMessage(
      conversation.id,
      content,
      message.timestamp,
    );

    // Increment unread count for receiver
    await _conversationRepository.incrementUnreadCount(
      conversation.id,
      receiverId,
    );

    return message;
  }

  /// Send automatic message when an offer is accepted
  Future<void> sendOfferAcceptedMessage(Order order) async {
    // Get user details to determine who is buyer and who is fisher
    final fisher = await _userRepository.getById(order.fisherId);
    final buyer = await _userRepository.getById(order.buyerId);

    if (fisher == null || buyer == null) {
      throw Exception('Fisher or buyer not found');
    }

    // Format the message - use kilograms and amount/amountPerKg properties
    final content =
        'Order accepted! ${order.terms.weight.kilograms}kg at ${order.terms.pricePerKg.amountPerKg} CFA/kg (Total: ${order.terms.totalPrice.amount} CFA)';

    // Send message to both users (system message)
    // We'll send it from fisher to buyer (arbitrary choice for system messages)
    await sendMessage(
      senderId: order.fisherId,
      receiverId: order.buyerId,
      content: content,
      isSystemMessage: true,
    );
  }

  /// Get all messages in a conversation and mark them as read for the current user
  Future<List<Message>> getConversationMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    // Get messages
    final messages = await _messageRepository.getMessagesByConversationId(
      conversationId,
    );

    // Mark all unread messages as read for current user
    await _messageRepository.markAllAsRead(conversationId, currentUserId);

    // Reset unread count in conversation
    await _conversationRepository.resetUnreadCount(
      conversationId,
      currentUserId,
    );

    return messages;
  }

  /// Get unread message count for a user across all conversations
  Future<int> getTotalUnreadCount(String userId) async {
    final conversations = await _conversationRepository.getConversationsForUser(
      userId,
    );

    int totalUnread = 0;
    for (final conversation in conversations) {
      totalUnread += conversation.getUnreadCountFor(userId);
    }

    return totalUnread;
  }

  /// Mark all messages in a conversation as read for a user
  Future<void> markConversationAsRead(
    String conversationId,
    String userId,
  ) async {
    // Mark all unread messages as read
    await _messageRepository.markAllAsRead(conversationId, userId);

    // Reset unread count in conversation
    await _conversationRepository.resetUnreadCount(conversationId, userId);
  }
}
