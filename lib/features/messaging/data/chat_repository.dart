import 'dart:async';

import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

class ChatRepository {
  final List<ChatThread> _threads = [
    ChatThread(
      id: 't1',
      participants: const ['solista@example.com', 'productor@example.com'],
      lastMessage: ChatMessage(
        id: 'm2',
        sender: 'productor@example.com',
        body: 'Nos vemos en el ensayo, ¿vale?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      unreadCount: 1,
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    't1': [
      ChatMessage(id: 'm1', sender: 'solista@example.com', body: '¿Confirmamos la sesión?', sentAt: DateTime.now().subtract(const Duration(minutes: 10)), isMine: true),
      ChatMessage(id: 'm2', sender: 'productor@example.com', body: 'Nos vemos en el ensayo, ¿vale?', sentAt: DateTime.now().subtract(const Duration(minutes: 5))),
    ],
  };

  Future<List<ChatThread>> fetchThreads() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _threads;
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _messages[threadId] ?? const [];
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'solista@example.com',
      body: body,
      sentAt: DateTime.now(),
      isMine: true,
    );
    _messages.putIfAbsent(threadId, () => []).add(message);
    return message;
  }
}
