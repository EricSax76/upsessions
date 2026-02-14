import 'package:equatable/equatable.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';

class ChatPageState extends Equatable {
  const ChatPageState({
    required this.threads,
    required this.messages,
    required this.selectedThread,
    required this.avatarUrlsByUserId,
    required this.lastMessageByThreadId,
    required this.errorMessage,
  });

  const ChatPageState.initial()
    : threads = const [],
      messages = const [],
      selectedThread = null,
      avatarUrlsByUserId = const {},
      lastMessageByThreadId = const {},
      errorMessage = null;

  final List<ChatThread> threads;
  final List<ChatMessage> messages;
  final ChatThread? selectedThread;
  final Map<String, String?> avatarUrlsByUserId;
  final Map<String, ChatMessage?> lastMessageByThreadId;
  final String? errorMessage;

  String get currentUserId => '';

  ChatPageState copyWith({
    List<ChatThread>? threads,
    List<ChatMessage>? messages,
    ChatThread? Function()? selectedThread,
    Map<String, String?>? avatarUrlsByUserId,
    Map<String, ChatMessage?>? lastMessageByThreadId,
    String? Function()? errorMessage,
  }) {
    return ChatPageState(
      threads: threads ?? this.threads,
      messages: messages ?? this.messages,
      selectedThread:
          selectedThread != null ? selectedThread() : this.selectedThread,
      avatarUrlsByUserId: avatarUrlsByUserId ?? this.avatarUrlsByUserId,
      lastMessageByThreadId:
          lastMessageByThreadId ?? this.lastMessageByThreadId,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    threads,
    messages,
    selectedThread,
    avatarUrlsByUserId,
    lastMessageByThreadId,
    errorMessage,
  ];
}
