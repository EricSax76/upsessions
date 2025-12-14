import 'package:flutter/material.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/announcements/data/announcements_repository.dart';
import 'package:upsessions/features/announcements/domain/announcement_entity.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/musicians/data/musicians_repository.dart';
import 'package:upsessions/modules/musicians/domain/musician_entity.dart';

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
  final MusiciansRepository _musiciansRepository = locate();
  final AnnouncementsRepository _announcementsRepository = locate();
  List<ChatThread> _threads = const [];
  List<ChatMessage> _messages = const [];
  ChatThread? _selectedThread;
  bool _creatingNewChat = false;

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

  Future<void> _startNewConversation() async {
    final target = await showDialog<_ConversationTarget>(
      context: context,
      builder: (context) => _NewConversationDialog(
        musiciansRepository: _musiciansRepository,
        announcementsRepository: _announcementsRepository,
      ),
    );
    if (target == null || !mounted) {
      return;
    }
    setState(() => _creatingNewChat = true);
    try {
      final thread = await _repository.ensureThreadWithParticipant(
        participantId: target.participantId,
        participantName: target.displayName,
      );
      if (!mounted) return;
      await _loadThreads(preferThreadId: thread.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el chat: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _creatingNewChat = false);
      }
    }
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
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _creatingNewChat ? null : _startNewConversation,
                    icon: _creatingNewChat
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_comment_rounded),
                    label: Text(_creatingNewChat ? 'Creando...' : 'Nuevo mensaje'),
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
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            onPressed: _creatingNewChat ? null : _startNewConversation,
            icon: _creatingNewChat
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_comment_rounded),
            tooltip: 'Nuevo mensaje',
          ),
        ],
      ),
      body: body,
    );
  }
}

class _ConversationTarget {
  const _ConversationTarget({required this.participantId, required this.displayName});

  final String participantId;
  final String displayName;
}

class _NewConversationDialog extends StatefulWidget {
  const _NewConversationDialog({
    required this.musiciansRepository,
    required this.announcementsRepository,
  });

  final MusiciansRepository musiciansRepository;
  final AnnouncementsRepository announcementsRepository;

  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  late Future<List<MusicianEntity>> _musiciansFuture;
  late Future<List<AnnouncementEntity>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _musiciansFuture = widget.musiciansRepository.search(limit: 50);
    _announcementsFuture = widget.announcementsRepository.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo mensaje'),
      content: SizedBox(
        width: 420,
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Músicos'),
                  Tab(text: 'Anuncios'),
                ],
              ),
              SizedBox(
                height: 320,
                child: TabBarView(
                  children: [
                    _AsyncListBuilder<MusicianEntity>(
                      future: _musiciansFuture,
                      emptyMessage: 'No hay músicos disponibles.',
                      itemBuilder: (context, musician) => ListTile(
                        title: Text(musician.name),
                        subtitle: Text('${musician.instrument} · ${musician.city}'),
                        onTap: () {
                          Navigator.of(context).pop(
                            _ConversationTarget(
                              participantId: musician.ownerId.isNotEmpty ? musician.ownerId : musician.id,
                              displayName: musician.name,
                            ),
                          );
                        },
                      ),
                    ),
                    _AsyncListBuilder<AnnouncementEntity>(
                      future: _announcementsFuture,
                      emptyMessage: 'No hay anuncios publicados.',
                      itemBuilder: (context, announcement) => ListTile(
                        title: Text(announcement.title),
                        subtitle: Text('${announcement.city} · ${announcement.author}'),
                        onTap: () {
                          Navigator.of(context).pop(
                            _ConversationTarget(
                              participantId: announcement.authorId,
                              displayName: announcement.author.isNotEmpty ? announcement.author : announcement.title,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _AsyncListBuilder<T> extends StatelessWidget {
  const _AsyncListBuilder({
    required this.future,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  final Future<List<T>> future;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'No pudimos cargar los datos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
            ),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      },
    );
  }
}
