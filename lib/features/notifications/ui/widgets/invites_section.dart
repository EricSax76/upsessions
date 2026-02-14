import 'package:flutter/material.dart';

import '../../models/invite_notification_entity.dart';

class InvitesSection extends StatelessWidget {
  const InvitesSection({
    super.key,
    required this.invites,
    required this.onOpenInvite,
  });

  final List<InviteNotificationEntity> invites;
  final void Function(InviteNotificationEntity invite) onOpenInvite;

  static String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Aceptada';
      case 'rejected':
        return 'Rechazada';
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (invites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              onTap: () => onOpenInvite(invite),
            ),
          ),
      ],
    );
  }
}
