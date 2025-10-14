import 'package:equatable/equatable.dart';

class ConversationPreview extends Equatable {
  final String id; // Maps to 'id' in DB
  final String buyerId;
  final String fisherId;

  // Denormalized contact fields (the other party)
  final String contactName; // Maps to 'contact_name' in DB
  final String contactAvatarPath; // Maps to 'contact_avatar_path' in DB

  final String lastMessageTime; // Maps to 'last_message_time' in DB
  final String lastMessage; // Maps to 'last_message' in DB
  final int unreadCount; // Maps to 'unread_count' in DB

  const ConversationPreview({
    required this.id,
    required this.buyerId,
    required this.fisherId,
    required this.contactName,
    required this.contactAvatarPath,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, lastMessageTime, unreadCount];

  Map<String, dynamic> toMap() => {
    'id': id,
    'buyer_id': buyerId,
    'fisher_id': fisherId,
    'contact_name': contactName,
    'contact_avatar_path': contactAvatarPath,
    'last_message_time': lastMessageTime,
    'last_message': lastMessage,
    'unread_count': unreadCount,
  };

  factory ConversationPreview.fromMap(Map<String, dynamic> m) =>
      ConversationPreview(
        id: m['id'] as String,
        buyerId: m['buyer_id'] as String,
        fisherId: m['fisher_id'] as String,
        contactName: m['contact_name'] as String,
        contactAvatarPath: m['contact_avatar_path'] as String,
        lastMessageTime: m['last_message_time'] as String,
        lastMessage: m['last_message'] as String,
        unreadCount: (m['unread_count'] as int?) ?? 0,
      );
}
