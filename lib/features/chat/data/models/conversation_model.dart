import 'package:siren_marketplace/core/data/models/user_model.dart';
import 'package:siren_marketplace/features/chat/data/models/message_model.dart';
import 'package:siren_marketplace/features/chat/domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.sourceAccount,
    required super.targetAccount,
    super.lastMessage,
    required super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      sourceAccount: UserModel.fromJson(json['sourceAccount']),
      targetAccount: UserModel.fromJson(json['targetAccount']),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id),
      'sourceAccount': (sourceAccount as UserModel).toJson(),
      'targetAccount': (targetAccount as UserModel).toJson(),
      'lastMessage': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
      'unreadCount': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
