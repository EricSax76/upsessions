import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../data/invite_notifications_repository.dart';
import '../../domain/invite_notification_entity.dart';

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
    return StreamBuilder<List<InviteNotificationEntity>>(
      stream: repository.watchMyInvites(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final invites = snapshot.data ?? const [];
        if (invites.isEmpty) {
          return Center(
            child: Text(
              'No tienes invitaciones pendientes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
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

  Future<void> _openInvite(
    BuildContext context,
    InviteNotificationsRepository repository,
    InviteNotificationEntity invite,
  ) async {
    await repository.markRead(invite.inviteId);
    if (!context.mounted) return;
    context.go(
      '${AppRoutes.invite}?groupId=${invite.groupId}&inviteId=${invite.inviteId}',
    );
  }
}
