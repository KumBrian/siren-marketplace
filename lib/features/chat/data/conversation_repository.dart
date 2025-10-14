import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'models/conversation_preview.dart';

class ConversationRepository {
  // Use dependency injection for better testing/flexibility
  final DatabaseHelper dbHelper;

  ConversationRepository({required this.dbHelper});

  static const String _tableName = 'conversations';

  // 1. Insert/Update a conversation preview
  Future<void> insertOrUpdateConversation(
    ConversationPreview conversation,
  ) async {
    final db = await dbHelper.database;
    await db.insert(
      _tableName,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. 🎯 UPDATED: Retrieve all conversation previews for a specific user,
  // regardless of their role (Buyer or Fisher).
  Future<List<ConversationPreview>> fetchConversationsForUser(
    String userId,
  ) async {
    // Uses the dedicated DatabaseHelper method for dual-role querying
    final maps = await dbHelper.getConversationsByUserId(userId);

    return maps.map((m) => ConversationPreview.fromMap(m)).toList();
  }

  // 3. Get a single conversation preview by ID
  Future<ConversationPreview?> getConversationById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return ConversationPreview.fromMap(maps.first);
    return null;
  }

  // 4. DELETE: Method to clean up conversations
  Future<void> deleteConversation(String id) async {
    final db = await dbHelper.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
