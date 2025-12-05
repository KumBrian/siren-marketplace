import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String buyerId;
  final String fisherId;
  final String lastMessage;
  final String lastMessageTime; // Stored as ISO8601 string
  final int unreadCountForBuyer;
  final int unreadCountForFisher;

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.fisherId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCountForBuyer,
    required this.unreadCountForFisher,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'fisher_id': fisherId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count_buyer': unreadCountForBuyer,
      'unread_count_fisher': unreadCountForFisher,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      buyerId: map['buyer_id'] as String,
      fisherId: map['fisher_id'] as String,
      lastMessage: map['last_message'] as String,
      lastMessageTime: map['last_message_time'] as String,
      unreadCountForBuyer: (map['unread_count_buyer'] as int?) ?? 0,
      unreadCountForFisher: (map['unread_count_fisher'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    buyerId,
    fisherId,
    lastMessage,
    lastMessageTime,
    unreadCountForBuyer,
    unreadCountForFisher,
  ];
}
