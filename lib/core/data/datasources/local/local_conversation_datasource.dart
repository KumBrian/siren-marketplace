import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/conversation.dart';
import '../../database/database_helper.dart';
import '../../models/conversation_model.dart';
import '../interfaces/i_conversation_datasource.dart';

class LocalConversationDataSource implements IConversationDataSource {
  final DatabaseHelper dbHelper;

  LocalConversationDataSource({required this.dbHelper});

  @override
  Future<ConversationModel> getOrCreate(String buyerId, String fisherId) async {
    // Generate conversation ID
    final conversationId = Conversation.generateId(buyerId, fisherId);

    // Try to get existing conversation
    final existing = await getById(conversationId);
    if (existing != null) {
      return existing;
    }

    // Create new conversation
    final newConversation = ConversationModel(
      id: conversationId,
      buyerId: buyerId,
      fisherId: fisherId,
      lastMessage: '',
      lastMessageTime: DateTime.now().toIso8601String(),
      unreadCountForBuyer: 0,
      unreadCountForFisher: 0,
    );

    final db = await dbHelper.database;
    await db.insert(
      'conversations',
      newConversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return newConversation;
  }

  @override
  Future<ConversationModel?> getById(String conversationId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [conversationId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ConversationModel.fromMap(maps.first);
  }

  @override
  Future<List<ConversationModel>> getByUserId(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'buyer_id = ? OR fisher_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'last_message_time DESC',
    );

    return maps.map((m) => ConversationModel.fromMap(m)).toList();
  }

  @override
  Future<void> update(ConversationModel conversation) async {
    final db = await dbHelper.database;
    await db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  @override
  Future<void> delete(String conversationId) async {
    final db = await dbHelper.database;
    await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }
}
