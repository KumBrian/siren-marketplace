import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/interfaces/i_conversation_datasource.dart';
import '../data/datasources/local/local_conversation_datasource.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../domain/entities/conversation.dart';
import '../domain/repositories/i_conversation_repository.dart';

// Database Helper Provider (reuse from message_providers if needed)
final _databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Conversation Data Source Provider
final _conversationDataSourceProvider = Provider<IConversationDataSource>((
  ref,
) {
  final dbHelper = ref.watch(_databaseHelperProvider);
  return LocalConversationDataSource(dbHelper: dbHelper);
});

// Conversation Repository Provider
final conversationRepositoryProvider = Provider<IConversationRepository>((ref) {
  final dataSource = ref.watch(_conversationDataSourceProvider);
  return ConversationRepositoryImpl(dataSource: dataSource);
});

// Conversations for current user
final userConversationsProvider =
    FutureProvider.family<List<Conversation>, String>((ref, userId) async {
      final repository = ref.watch(conversationRepositoryProvider);
      return await repository.getConversationsForUser(userId);
    });

// Single conversation by ID
final conversationProvider = FutureProvider.family<Conversation?, String>((
  ref,
  conversationId,
) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return await repository.getById(conversationId);
});
