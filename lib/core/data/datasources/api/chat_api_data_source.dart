import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_model.dart';
import 'package:siren_marketplace/features/chat/data/models/message_model.dart';

class ChatApiDataSource {
  final ApiClient _client;

  ChatApiDataSource(this._client);

  Future<ConversationModel> openConversation(Map<String, dynamic> body) async {
    final response = await _client.post('/conversations/open', data: body);
    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }
    return ConversationModel.fromJson(data);
  }

  Future<List<ConversationModel>> getMyConversations() async {
    final response = await _client.get('/conversations/my-conversations');
    // Handle Hydra/API Platform collection format
    final data = response.data;
    List conversations = [];

    if (data is Map<String, dynamic>) {
      if (data.containsKey('member')) {
        conversations = data['member'];
      } else if (data['data'] != null && data['data'] is Map) {
        conversations = data['data']['member'] ?? [];
      } else if (data['data'] is List) {
        conversations = data['data'];
      }
    } else if (data is List) {
      conversations = data;
    }

    return conversations.map((e) => ConversationModel.fromJson(e)).toList();
  }

  Future<List<MessageModel>> getMessages(String id) async {
    final response = await _client.get('/conversations/$id/messages');

    // Handle Hydra/API Platform collection format
    final data = response.data;
    List messages = [];

    if (data is Map<String, dynamic>) {
      if (data.containsKey('member')) {
        messages = data['member'];
      } else if (data['data'] != null && data['data'] is Map) {
        messages = data['data']['member'] ?? [];
      } else if (data['data'] is List) {
        messages = data['data'];
      }
    } else if (data is List) {
      messages = data;
    }

    return messages.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(Map<String, dynamic> body) async {
    await _client.post('/messages/mark-as-read', data: body);
  }

  Future<MessageModel> sendMessage(Map<String, dynamic> body) async {
    final response = await _client.post('/messages/send', data: body);
    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }
    return MessageModel.fromJson(data);
  }
}
