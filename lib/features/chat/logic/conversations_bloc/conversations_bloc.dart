import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final ConversationRepository repository;

  ConversationsBloc(this.repository) : super(ConversationsInitial()) {
    on<LoadConversations>(_onLoadConversations);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(ConversationsLoading());
    try {
      // 🎯 UPDATED: Use the new scoped repository method and pass the buyerId from the event
      final conversations = await repository.fetchConversationsForUser(
        event.buyerId,
      );

      emit(ConversationsLoaded(conversations));
    } catch (e) {
      // It's professional to log the error here if possible
      print('Error loading conversations: $e');
      emit(
        const ConversationsError('Failed to load messages. Please try again.'),
      );
    }
  }
}
