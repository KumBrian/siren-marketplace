import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final User sender;
  final User receiver;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.receiver,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    sender,
    receiver,
    isRead,
    readAt,
    createdAt,
  ];
}
