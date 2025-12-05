import 'package:uuid/uuid.dart';

import '../../database/database_helper.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class MessageSeeder {
  final DatabaseHelper dbHelper;
  static const _uuid = Uuid();

  MessageSeeder({required this.dbHelper});

  Future<void> seed() async {
    print('Seeding messages and conversations...');

    // Get existing users from the database to create realistic conversations
    final db = await dbHelper.database;
    final users = await db.query('users');

    if (users.length < 2) {
      print(
        'Not enough users to create conversations. Skipping message seeding.',
      );
      return;
    }

    // Find a buyer and a fisher
    final buyer = users.firstWhere(
      (u) => u['role'] == 'buyer',
      orElse: () => users.first,
    );
    final fisher = users.firstWhere(
      (u) => u['role'] == 'fisher',
      orElse: () => users.last,
    );

    final buyerId = buyer['id'] as String;
    final fisherId = fisher['id'] as String;

    // Generate conversation ID
    final conversationId = _generateConversationId(buyerId, fisherId);

    // Check if conversation already exists
    final existingConversations = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [conversationId],
    );

    if (existingConversations.isNotEmpty) {
      print(
        'Conversation already exists. Skipping message seeding to avoid duplicates.',
      );
      return;
    }

    // Create conversation
    final conversation = ConversationModel(
      id: conversationId,
      buyerId: buyerId,
      fisherId: fisherId,
      lastMessage: 'Great! I\'ll be there at 4 PM.',
      lastMessageTime: DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      unreadCountForBuyer: 0,
      unreadCountForFisher: 1,
    );

    await db.insert('conversations', conversation.toMap());

    // Create some sample messages
    final messages = [
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: buyerId,
        receiverId: fisherId,
        content: 'Hi! Are you still selling the fish?',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 1, hours: 2))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: fisherId,
        receiverId: buyerId,
        content: 'Yes, I have some fresh catch. What quantity do you need?',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 1, hours: 1, minutes: 55))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: buyerId,
        receiverId: fisherId,
        content: 'I need about 6kg. What\'s your price?',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 1, hours: 1, minutes: 50))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: fisherId,
        receiverId: buyerId,
        content: '2500 CFA per kg. Very fresh, caught this morning.',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: buyerId,
        receiverId: fisherId,
        content: 'Perfect! When can we meet for the exchange?',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: fisherId,
        receiverId: buyerId,
        content: 'I am available this afternoon at the market.',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 30))
            .toIso8601String(),
        isRead: 1,
        isSystemMessage: 0,
      ),
      MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: buyerId,
        receiverId: fisherId,
        content: 'Great! I\'ll be there at 4 PM.',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        isRead: 0,
        isSystemMessage: 0,
      ),
    ];

    for (final message in messages) {
      await db.insert('messages', message.toMap());
    }

    print('Seeded ${messages.length} messages and 1 conversation.');
  }

  String _generateConversationId(String buyerId, String fisherId) {
    final ids = [buyerId, fisherId]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
