import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../messaging/repositories/chat_repository.dart';
import '../../../messaging/models/chat_thread.dart';
import '../../../../modules/auth/repositories/auth_repository.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../repositories/invite_notifications_repository.dart';
import '../../models/invite_notification_entity.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: _NotificationsView());
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final repository = locate<InviteNotificationsRepository>();
    final chatRepository = locate<ChatRepository>();
    final authRepository = locate<AuthRepository>();

    return StreamBuilder<List<ChatThread>>(
      stream: chatRepository.watchThreads(),
      builder: (context, threadsSnapshot) {
        return StreamBuilder<List<InviteNotificationEntity>>(
          stream: repository.watchMyInvites(),
          builder: (context, invitesSnapshot) {
            if (threadsSnapshot.hasError) {
              return Center(child: Text('Error: ${threadsSnapshot.error}'));
            }
            if (invitesSnapshot.hasError) {
              return Center(child: Text('Error: ${invitesSnapshot.error}'));
            }
            if (threadsSnapshot.connectionState == ConnectionState.waiting ||
                invitesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUserId = authRepository.currentUser?.id ?? '';
            final threads = threadsSnapshot.data ?? const <ChatThread>[];
            final invites =
                invitesSnapshot.data ?? const <InviteNotificationEntity>[];

            final unreadThreads = threads
                .where((thread) => thread.unreadCount > 0)
                .toList(growable: false);

            if (unreadThreads.isEmpty && invites.isEmpty) {
              return Center(
                child: Text(
                  'No tienes notificaciones.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                if (unreadThreads.isNotEmpty) ...[
                  Text(
                    'Mensajes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  for (final thread in unreadThreads)
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
                        trailing: _UnreadCountChip(count: thread.unreadCount),
                        onTap: () =>
                            _openThread(context, chatRepository, thread.id),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                if (invites.isNotEmpty) ...[
                  Text(
                    'Invitaciones',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  for (final invite in invites)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          invite.read ? Icons.mail_outline : Icons.mail,
                        ),
                        title: Text(
                          invite.groupName.isEmpty ? 'Grupo' : invite.groupName,
                        ),
                        subtitle: Text(_statusLabel(invite.status)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openInvite(context, repository, invite),
                      ),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Aceptada';
      case 'rejected':
        return 'Rechazada';
      default:
        return 'Pendiente';
    }
  }

  Future<void> _openThread(
    BuildContext context,
    ChatRepository repository,
    String threadId,
  ) async {
    repository.markThreadRead(threadId);
    if (!context.mounted) return;
    context.push(AppRoutes.messagesThreadPath(threadId));
  }

  Future<void> _openInvite(
    BuildContext context,
    InviteNotificationsRepository repository,
    InviteNotificationEntity invite,
  ) async {
    await repository.markRead(invite.inviteId);
    if (!context.mounted) return;
    context.go(
      AppRoutes.invitePath(groupId: invite.groupId, inviteId: invite.inviteId),
    );
  }
}

class _UnreadCountChip extends StatelessWidget {
  const _UnreadCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
