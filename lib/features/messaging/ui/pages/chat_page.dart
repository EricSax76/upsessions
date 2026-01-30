import 'package:flutter/material.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/auth/data/profile_repository.dart';

import '../../repositories/chat_repository.dart';
import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_thread_list_item.dart';
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
  final ProfileRepository _profileRepository = locate();
  List<ChatThread> _threads = const [];
  List<ChatMessage> _messages = const [];
  ChatThread? _selectedThread;
  bool _didAutoOpenInitialThread = false;
  final Map<String, String?> _avatarUrlsByUserId = <String, String?>{};
  final Map<String, ChatMessage?> _lastMessageByThreadId =
      <String, ChatMessage?>{};

  @override
  void initState() {
    super.initState();
    _loadThreads(preferThreadId: widget.initialThreadId);
  }

  Future<void> _loadThreads({String? preferThreadId}) async {
    try {
      var threads = await _repository.fetchThreads();
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
      if (selected == null && targetThreadId != null) {
        final thread = await _repository.fetchThread(targetThreadId);
        if (thread != null) {
          threads = [
            thread,
            ...threads.where((existing) => existing.id != thread.id),
          ];
          selected = thread;
        }
      }
      selected ??= threads.isNotEmpty ? threads.first : null;
      if (!mounted) return;
      setState(() {
        _threads = threads;
        _selectedThread = selected;
      });
      await _prefetchParticipantAvatars(threads);
      await _prefetchThreadLastMessages(threads);
      if (selected != null) {
        await _loadMessages(selected.id);
        if (!_didAutoOpenInitialThread && preferThreadId != null) {
          _didAutoOpenInitialThread = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final isCompact = MediaQuery.sizeOf(context).width < 720;
            final thread = _selectedThread;
            final currentUserId = _authRepository.currentUser?.id ?? '';
            if (isCompact && thread != null) {
              _openThreadDetail(thread, currentUserId);
            }
          });
        }
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

  bool _isNoMessagesPlaceholder(ChatMessage message) {
    return message.id.isEmpty ||
        message.body.trim().toLowerCase() == 'aún no hay mensajes.';
  }

  String? _otherParticipantId(ChatThread thread, String currentUserId) {
    for (final participantId in thread.participants) {
      if (participantId != currentUserId) {
        return participantId;
      }
    }
    return null;
  }

  Future<void> _prefetchParticipantAvatars(List<ChatThread> threads) async {
    final currentUserId = _authRepository.currentUser?.id;
    if (currentUserId == null || currentUserId.trim().isEmpty) return;

    final idsToFetch = <String>{};
    for (final thread in threads) {
      final otherId = _otherParticipantId(thread, currentUserId);
      if (otherId == null) continue;
      if (_avatarUrlsByUserId.containsKey(otherId)) continue;
      idsToFetch.add(otherId);
    }
    if (idsToFetch.isEmpty) return;

    final results = await Future.wait(
      idsToFetch.map((id) async {
        try {
          final profile = await _profileRepository.fetchProfile(profileId: id);
          return MapEntry(id, profile.photoUrl);
        } catch (_) {
          return MapEntry(id, null);
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      for (final entry in results) {
        _avatarUrlsByUserId[entry.key] = entry.value;
      }
    });
  }

  Future<void> _prefetchThreadLastMessages(List<ChatThread> threads) async {
    final idsToFetch = <String>{};
    for (final thread in threads) {
      if (_lastMessageByThreadId.containsKey(thread.id)) continue;
      if (_isNoMessagesPlaceholder(thread.lastMessage)) {
        idsToFetch.add(thread.id);
      } else {
        _lastMessageByThreadId[thread.id] = thread.lastMessage;
      }
    }
    if (idsToFetch.isEmpty) return;

    final results = await Future.wait(
      idsToFetch.map((threadId) async {
        final message = await _repository.fetchLastMessage(threadId);
        return MapEntry(threadId, message);
      }),
    );

    if (!mounted) return;
    setState(() {
      for (final entry in results) {
        _lastMessageByThreadId[entry.key] = entry.value;
      }
    });
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
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              Expanded(
                child: hasSelectedThread
                    ? ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            MessageBubble(message: _messages[index]),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Selecciona una conversación',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (hasSelectedThread)
                ChatInputField(onSend: _sendMessage)
              else
                const SizedBox.shrink(),
            ],
          ),
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
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _threads.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final thread = _threads[index];
          final title = thread.titleFor(currentUserId);
          final otherId = _otherParticipantId(thread, currentUserId);
          final avatarUrl =
              otherId == null ? null : _avatarUrlsByUserId[otherId];
          final lastMessage =
              _lastMessageByThreadId[thread.id] ?? thread.lastMessage;
          final subtitle = _isNoMessagesPlaceholder(lastMessage)
              ? ''
              : lastMessage.body;
          return ChatThreadListItem(
            title: title,
            subtitle: subtitle,
            avatarUrl: avatarUrl,
            unreadCount: thread.unreadCount,
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
            SizedBox(
              width: 320, 
              child: buildThreadsList(false)
            ),
            const SizedBox(width: 8), 
            buildConversationPane(),
          ],
        );
      },
    );

    if (!widget.showAppBar) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: body,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: body,
    );
  }
}
