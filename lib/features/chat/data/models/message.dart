import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String messageId;
  final String clientName;
  final String lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final String avatarPath;

  const Message({
    required this.messageId,
    required this.clientName,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.unreadCount,
    required this.avatarPath,
  });

  @override
  List<Object> get props => [
    messageId,
    clientName,
    lastMessageTime,
    lastMessage,
    unreadCount,
    avatarPath,
  ];
}
