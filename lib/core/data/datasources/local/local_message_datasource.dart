import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/message_model.dart';
import '../interfaces/i_message_datasource.dart';

class LocalMessageDataSource implements IMessageDataSource {
  final DatabaseHelper dbHelper;

  LocalMessageDataSource({required this.dbHelper});

  @override
  Future<String> create(MessageModel message) async {
    final db = await dbHelper.database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return message.id;
  }

  @override
  Future<List<MessageModel>> getByConversationId(String conversationId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((m) => MessageModel.fromMap(m)).toList();
  }

  @override
  Future<void> markAsRead(String messageId) async {
    final db = await dbHelper.database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  @override
  Future<int> getUnreadCount(String conversationId, String userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM messages
      WHERE conversation_id = ? AND receiver_id = ? AND is_read = 0
      ''',
      [conversationId, userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> markAllAsRead(String conversationId, String userId) async {
    final db = await dbHelper.database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'conversation_id = ? AND receiver_id = ? AND is_read = 0',
      whereArgs: [conversationId, userId],
    );
  }

  @override
  Future<void> delete(String messageId) async {
    final db = await dbHelper.database;
    await db.delete('messages', where: 'id = ?', whereArgs: [messageId]);
  }
}
