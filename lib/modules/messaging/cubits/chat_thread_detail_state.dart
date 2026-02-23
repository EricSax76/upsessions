import 'package:equatable/equatable.dart';

import '../models/chat_message.dart';

class ChatThreadDetailState extends Equatable {
  const ChatThreadDetailState({
    required this.messages,
    required this.isLoading,
    required this.errorMessage,
  });

  const ChatThreadDetailState.initial()
    : messages = const [],
      isLoading = true,
      errorMessage = null;

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatThreadDetailState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return ChatThreadDetailState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
}
