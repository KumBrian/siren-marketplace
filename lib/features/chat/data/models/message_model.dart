import 'package:siren_marketplace/core/data/models/user_model.dart';
import 'package:siren_marketplace/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.sender,
    required super.receiver,
    required super.isRead,
    super.readAt,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] as String,
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id),
      'content': content,
      'sender': (sender as UserModel).toJson(),
      'receiver': (receiver as UserModel).toJson(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
