import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/interfaces/i_message_datasource.dart';
import '../data/datasources/local/local_message_datasource.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/message_repository_impl.dart';
import '../domain/entities/message.dart';
import '../domain/repositories/i_message_repository.dart';

// Database Helper Provider
final _databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Message Data Source Provider
final _messageDataSourceProvider = Provider<IMessageDataSource>((ref) {
  final dbHelper = ref.watch(_databaseHelperProvider);
  return LocalMessageDataSource(dbHelper: dbHelper);
});

// Message Repository Provider
final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  final dataSource = ref.watch(_messageDataSourceProvider);
  return MessageRepositoryImpl(dataSource: dataSource);
});

// Messages for a specific conversation
final conversationMessagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
      final repository = ref.watch(messageRepositoryProvider);
      return await repository.getMessagesByConversationId(conversationId);
    });

// Unread count for a conversation
final conversationUnreadCountProvider =
    FutureProvider.family<int, ({String conversationId, String userId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(messageRepositoryProvider);
      return await repository.getUnreadCount(
        params.conversationId,
        params.userId,
      );
    });
