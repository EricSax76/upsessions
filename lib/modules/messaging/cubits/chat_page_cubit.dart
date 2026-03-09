import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/repositories/auth_repository.dart';
import '../../../modules/auth/repositories/profile_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../repositories/chat_repository.dart';
import 'chat_page_state.dart';

export 'chat_page_state.dart';

// ──────────────────────────────────────────────
//  Cubit
// ──────────────────────────────────────────────

class ChatPageCubit extends Cubit<ChatPageState> {
  ChatPageCubit({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _chatRepository = chatRepository,
       _authRepository = authRepository,
       _profileRepository = profileRepository,
       super(const ChatPageState.initial());

  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  String get currentUserId => _authRepository.currentUser?.id ?? '';

  // ── Load threads ──────────────────────────

  Future<void> loadThreads({String? preferThreadId}) async {
    try {
      var threads = await _chatRepository.fetchThreads();
      ChatThread? selected;
      final targetThreadId = preferThreadId ?? state.selectedThread?.id;

      if (targetThreadId != null) {
        for (final thread in threads) {
          if (thread.id == targetThreadId) {
            selected = thread;
            break;
          }
        }
      }

      if (selected == null && targetThreadId != null) {
        final thread = await _chatRepository.fetchThread(targetThreadId);
        if (thread != null) {
          threads = [
            thread,
            ...threads.where((existing) => existing.id != thread.id),
          ];
          selected = thread;
        }
      }

      selected ??= threads.isNotEmpty ? threads.first : null;
      if (isClosed) return;

      emit(
        state.copyWith(
          threads: threads,
          selectedThread: () => selected,
          errorMessage: () => null,
        ),
      );

      await _prefetchAvatars(threads);
      _hydrateLastMessagesFromThreads(threads);

      if (selected != null) {
        await loadMessages(selected.id);
      } else {
        if (!isClosed) emit(state.copyWith(messages: const []));
      }
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          threads: const [],
          messages: const [],
          selectedThread: () => null,
          errorMessage: () => 'No se pudieron cargar los chats: $error',
        ),
      );
    }
  }

  // ── Select thread ─────────────────────────

  Future<void> selectThread(ChatThread thread) async {
    emit(state.copyWith(selectedThread: () => thread));
    await loadMessages(thread.id);
  }

  // ── Load messages ─────────────────────────

  Future<void> loadMessages(String threadId) async {
    try {
      final messages = await _chatRepository.fetchMessages(threadId);
      if (isClosed) return;
      final updatedLastMessages = Map<String, ChatMessage?>.from(
        state.lastMessageByThreadId,
      );
      if (messages.isNotEmpty) {
        updatedLastMessages[threadId] = messages.last;
      }
      emit(
        state.copyWith(
          messages: messages,
          lastMessageByThreadId: updatedLastMessages,
        ),
      );

      var threadUnreadCount = 0;
      if (state.selectedThread?.id == threadId) {
        threadUnreadCount = state.selectedThread?.unreadCount ?? 0;
      } else {
        for (final thread in state.threads) {
          if (thread.id == threadId) {
            threadUnreadCount = thread.unreadCount;
            break;
          }
        }
      }
      if (threadUnreadCount > 0) {
        _chatRepository.markThreadRead(threadId);
      }
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          errorMessage: () => 'No se pudieron cargar los mensajes: $error',
        ),
      );
    }
  }

  // ── Send message ──────────────────────────

  Future<void> sendMessage(String text) async {
    final thread = state.selectedThread;
    if (thread == null) return;
    try {
      final message = await _chatRepository.sendMessage(thread.id, text);
      if (isClosed) return;
      final updatedLastMessages = Map<String, ChatMessage?>.from(
        state.lastMessageByThreadId,
      )..[thread.id] = message;
      emit(
        state.copyWith(
          messages: [...state.messages, message],
          lastMessageByThreadId: updatedLastMessages,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          errorMessage: () => 'No se pudo enviar el mensaje: $error',
        ),
      );
    }
  }

  // ── Prefetch helpers ──────────────────────

  String? _otherParticipantId(ChatThread thread, String userId) {
    for (final participantId in thread.participants) {
      if (participantId != userId) return participantId;
    }
    return null;
  }

  Future<void> _prefetchAvatars(List<ChatThread> threads) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) return;

    final idsToFetch = <String>{};
    for (final thread in threads) {
      final otherId = _otherParticipantId(thread, userId);
      if (otherId == null) continue;
      if (state.avatarUrlsByUserId.containsKey(otherId)) continue;
      idsToFetch.add(otherId);
    }
    if (idsToFetch.isEmpty) return;

    final photoMap = await _profileRepository.fetchProfilePhotos(
      idsToFetch.toList(),
    );

    if (isClosed) return;
    final updated = Map<String, String?>.from(state.avatarUrlsByUserId);
    updated.addAll(photoMap);
    emit(state.copyWith(avatarUrlsByUserId: updated));
  }

  static bool isNoMessagesPlaceholder(ChatMessage message) {
    return message.id.isEmpty ||
        message.body.trim().toLowerCase() == 'aún no hay mensajes.';
  }

  void _hydrateLastMessagesFromThreads(List<ChatThread> threads) {
    final current = Map<String, ChatMessage?>.from(state.lastMessageByThreadId);
    for (final thread in threads) {
      final cached = current[thread.id];
      if (cached != null && !isNoMessagesPlaceholder(cached)) {
        continue;
      }
      final fromThread = thread.lastMessage;
      current[thread.id] = isNoMessagesPlaceholder(fromThread)
          ? null
          : fromThread;
    }
    if (isClosed) return;
    emit(state.copyWith(lastMessageByThreadId: current));
  }
}
