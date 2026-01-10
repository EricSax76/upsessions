import 'package:flutter/material.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';

import '../../repositories/chat_repository.dart';
import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';
import 'chat_thread_detail_page.dart';

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
    _loadThreads(preferThreadId: widget.initialThreadId);
  }

  Future<void> _loadThreads({String? preferThreadId}) async {
    try {
      final threads = await _repository.fetchThreads();
      ChatThread? selected;
      final targetThreadId = preferThreadId ?? _selectedThread?.id;
      if (targetThreadId != null) {
        for (final thread in threads) {
          if (thread.id == targetThreadId) {
            selected = thread;
            break;
          }
        }
      }
      selected ??= threads.isNotEmpty ? threads.first : null;
      if (!mounted) return;
      setState(() {
        _threads = threads;
        _selectedThread = selected;
      });
      if (selected != null) {
        await _loadMessages(selected.id);
      } else {
        if (mounted) {
          setState(() => _messages = const []);
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _threads = const [];
        _messages = const [];
        _selectedThread = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los chats: $error')),
      );
    }
  }

  Future<void> _loadMessages(String threadId) async {
    try {
      final messages = await _repository.fetchMessages(threadId);
      if (!mounted) return;
      setState(() => _messages = messages);
      var threadUnreadCount = 0;
      if (_selectedThread?.id == threadId) {
        threadUnreadCount = _selectedThread?.unreadCount ?? 0;
      } else {
        for (final thread in _threads) {
          if (thread.id == threadId) {
            threadUnreadCount = thread.unreadCount;
            break;
          }
        }
      }
      if (threadUnreadCount > 0) {
        _repository.markThreadRead(threadId);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los mensajes: $error')),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    final thread = _selectedThread;
    if (thread == null) return;
    try {
      final message = await _repository.sendMessage(thread.id, text);
      if (!mounted) return;
      setState(() => _messages = [..._messages, message]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el mensaje: $error')),
      );
    }
  }

  Future<void> _openThreadDetail(
    ChatThread thread,
    String currentUserId,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatThreadDetailPage(
          thread: thread,
          threadTitle: thread.titleFor(currentUserId),
        ),
      ),
    );
    if (!mounted) return;
    await _loadThreads(preferThreadId: thread.id);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authRepository.currentUser?.id ?? '';
    final hasSelectedThread = _selectedThread != null;

    Widget buildConversationPane() {
      return Expanded(
        child: Column(
          children: [
            Expanded(
              child: hasSelectedThread
                  ? ListView.builder(
                      reverse: true,
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
    }

    Widget buildThreadsList(bool isCompact) {
      if (_threads.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Aún no hay conversaciones.'),
          ),
        );
      }
      return ListView.builder(
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
            selected: !isCompact && thread.id == _selectedThread?.id,
            onTap: () {
              if (isCompact) {
                _openThreadDetail(thread, currentUserId);
              } else {
                setState(() => _selectedThread = thread);
                _loadMessages(thread.id);
              }
            },
          );
        },
      );
    }

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        if (isCompact) {
          return buildThreadsList(true);
        }
        return Row(
          children: [
            SizedBox(width: 260, child: buildThreadsList(false)),
            const VerticalDivider(width: 1),
            buildConversationPane(),
          ],
        );
      },
    );

    if (!widget.showAppBar) {
      return SafeArea(
        child: Column(
          children: [
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
