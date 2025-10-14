// lib/bloc/conversations_bloc/conversations_state.dart

part of 'conversations_bloc.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object> get props => [];
}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationPreview> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object> get props => [message];
}
