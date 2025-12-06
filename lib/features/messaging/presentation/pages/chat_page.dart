import 'package:flutter/material.dart';

import 'package:upsessions/core/locator/locator.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_thread.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatRepository _repository = locate();
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
    setState(() {
      _threads = threads;
      _selectedThread = threads.isNotEmpty ? threads.first : null;
    });
    if (_selectedThread != null) {
      _loadMessages(_selectedThread!.id);
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
    final conversationPane = Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  MessageBubble(message: _messages[index]),
            ),
          ),
          ChatInputField(onSend: _sendMessage),
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
                title: Text(thread.participants.last),
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
