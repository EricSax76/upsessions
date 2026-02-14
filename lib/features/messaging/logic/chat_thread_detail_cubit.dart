import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/chat_repository.dart';
import 'chat_thread_detail_state.dart';

export 'chat_thread_detail_state.dart';

class ChatThreadDetailCubit extends Cubit<ChatThreadDetailState> {
  ChatThreadDetailCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatThreadDetailState.initial());

  final ChatRepository _chatRepository;

  Future<void> loadMessages(String threadId, {int unreadCount = 0}) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final messages = await _chatRepository.fetchMessages(threadId);
      if (isClosed) return;
      emit(state.copyWith(messages: messages, isLoading: false));

      if (unreadCount > 0) {
        _chatRepository.markThreadRead(threadId);
      }
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'No se pudieron cargar los mensajes: $error',
      ));
    }
  }

  Future<void> sendMessage(String threadId, String text) async {
    try {
      final message = await _chatRepository.sendMessage(threadId, text);
      if (isClosed) return;
      emit(state.copyWith(messages: [...state.messages, message]));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        errorMessage: () => 'No se pudo enviar el mensaje: $error',
      ));
    }
  }

  void markRead(String threadId) {
    _chatRepository.markThreadRead(threadId);
  }
}
