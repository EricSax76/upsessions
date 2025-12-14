import 'package:flutter/material.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';

import '../../data/chat_repository.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_thread.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.showAppBar = true, this.initialThreadId});

  final bool showAppBar;
  final String? initialThreadId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatRepository _repository = locate();
  final AuthRepository _authRepository = locate();
  List<ChatThread> _threads = const [];
  List<ChatMessage> _messages = const [];
  ChatThread? _selectedThread;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    final threads = await _repository.fetchThreads();
    ChatThread? selected;
    if (widget.initialThreadId != null) {
      for (final thread in threads) {
        if (thread.id == widget.initialThreadId) {
          selected = thread;
          break;
        }
      }
    }
    selected ??= threads.isNotEmpty ? threads.first : null;
    setState(() {
      _threads = threads;
      _selectedThread = selected;
    });
    if (selected != null) {
      _loadMessages(selected.id);
    } else {
      setState(() => _messages = const []);
    }
  }

  Future<void> _loadMessages(String threadId) async {
    final messages = await _repository.fetchMessages(threadId);
    setState(() => _messages = messages);
  }

  Future<void> _sendMessage(String text) async {
    final thread = _selectedThread;
    if (thread == null) return;
    final message = await _repository.sendMessage(thread.id, text);
    setState(() => _messages = [..._messages, message]);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authRepository.currentUser?.id ?? '';
    final hasSelectedThread = _selectedThread != null;
    final conversationPane = Expanded(
      child: Column(
        children: [
          Expanded(
            child: hasSelectedThread
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        MessageBubble(message: _messages[index]),
                  )
                : const Center(
                    child: Text('Selecciona una conversación para empezar.'),
                  ),
          ),
          if (hasSelectedThread)
            ChatInputField(onSend: _sendMessage)
          else
            const SizedBox.shrink(),
        ],
      ),
    );

    final body = Row(
      children: [
        SizedBox(
          width: 260,
          child: ListView.builder(
            itemCount: _threads.length,
            itemBuilder: (context, index) {
              final thread = _threads[index];
              return ListTile(
                title: Text(thread.titleFor(currentUserId)),
                subtitle: Text(
                  thread.lastMessage.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: thread.id == _selectedThread?.id,
                onTap: () {
                  setState(() => _selectedThread = thread);
                  _loadMessages(thread.id);
                },
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        conversationPane,
      ],
    );

    if (!widget.showAppBar) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mensajes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mantén tus conversaciones organizadas en un solo lugar.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: body,
    );
  }
}
