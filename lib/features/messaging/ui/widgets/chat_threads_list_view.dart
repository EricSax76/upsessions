import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';
import 'chat_thread_list_item.dart';

class ChatThreadsListView extends StatelessWidget {
  const ChatThreadsListView({
    super.key,
    required this.threads,
    required this.currentUserId,
    required this.selectedThreadId,
    required this.avatarUrlsByUserId,
    required this.lastMessageByThreadId,
    required this.isCompact,
    required this.onSelectThread,
    required this.onOpenThreadDetail,
  });

  final List<ChatThread> threads;
  final String currentUserId;
  final String? selectedThreadId;
  final Map<String, String?> avatarUrlsByUserId;
  final Map<String, ChatMessage?> lastMessageByThreadId;
  final bool isCompact;
  final void Function(ChatThread thread) onSelectThread;
  final void Function(ChatThread thread) onOpenThreadDetail;

  static bool _isNoMessagesPlaceholder(ChatMessage message) {
    return message.id.isEmpty ||
        message.body.trim().toLowerCase() == 'aún no hay mensajes.';
  }

  static String? _otherParticipantId(ChatThread thread, String currentUserId) {
    for (final participantId in thread.participants) {
      if (participantId != currentUserId) {
        return participantId;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aún no hay conversaciones.'),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: threads.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final thread = threads[index];
        final title = thread.titleFor(currentUserId);
        final otherId = _otherParticipantId(thread, currentUserId);
        final avatarUrl = otherId == null
            ? null
            : avatarUrlsByUserId[otherId];
        final lastMessage =
            lastMessageByThreadId[thread.id] ?? thread.lastMessage;
        final subtitle = _isNoMessagesPlaceholder(lastMessage)
            ? ''
            : lastMessage.body;
        return ChatThreadListItem(
          title: title,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          unreadCount: thread.unreadCount,
          selected: !isCompact && thread.id == selectedThreadId,
          onTap: () {
            if (isCompact) {
              onOpenThreadDetail(thread);
            } else {
              onSelectThread(thread);
            }
          },
        );
      },
    );
  }
}
