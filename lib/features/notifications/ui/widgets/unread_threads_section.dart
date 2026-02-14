import 'package:flutter/material.dart';

import '../../../messaging/models/chat_thread.dart';
import 'notification_badge.dart';

class UnreadThreadsSection extends StatelessWidget {
  const UnreadThreadsSection({
    super.key,
    required this.threads,
    required this.currentUserId,
    required this.onOpenThread,
  });

  final List<ChatThread> threads;
  final String currentUserId;
  final void Function(String threadId) onOpenThread;

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mensajes',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        for (final thread in threads)
          Card(
            child: ListTile(
              leading: const Icon(Icons.message_outlined),
              title: Text(
                currentUserId.isEmpty
                    ? 'Conversación'
                    : thread.titleFor(currentUserId),
              ),
              subtitle: Text(
                thread.lastMessage.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: NotificationBadge(count: thread.unreadCount),
              onTap: () => onOpenThread(thread.id),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
