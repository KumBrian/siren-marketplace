// lib/bloc/conversations_bloc/conversations_event.dart

part of 'conversations_bloc.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object> get props => [];
}

// 🆕 Event now requires the buyerId to scope the request
class LoadConversations extends ConversationsEvent {
  final String buyerId;

  const LoadConversations({required this.buyerId});

  @override
  List<Object> get props => [buyerId];
}
