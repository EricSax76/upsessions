import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../auth/repositories/auth_repository.dart';
import '../../../../musicians/repositories/musician_notifications_repository.dart';
import '../invites_section.dart';
import '../unread_threads_section.dart';
import 'notification_center_empty_state.dart';
import 'notification_center_error_view.dart';

class MusicianNotificationsPanel extends StatelessWidget {
  const MusicianNotificationsPanel({super.key, required this.repository});

  final MusicianNotificationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthRepository>().currentUser?.id ?? '';

    return StreamBuilder(
      stream: repository.watchUnreadThreads(),
      builder: (context, unreadThreadsSnapshot) {
        return StreamBuilder(
          stream: repository.watchInvites(),
          builder: (context, invitesSnapshot) {
            if (unreadThreadsSnapshot.hasError) {
              return NotificationCenterErrorView(
                message: unreadThreadsSnapshot.error.toString(),
              );
            }
            if (invitesSnapshot.hasError) {
              return NotificationCenterErrorView(
                message: invitesSnapshot.error.toString(),
              );
            }
            if (!unreadThreadsSnapshot.hasData || !invitesSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final unreadThreads = unreadThreadsSnapshot.data!;
            final invites = invitesSnapshot.data!;

            if (unreadThreads.isEmpty && invites.isEmpty) {
              return const NotificationCenterEmptyState(
                icon: Icons.mark_email_read_outlined,
                title: 'Todo al día',
                description:
                    'No tienes mensajes sin leer ni invitaciones pendientes.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnreadThreadsSection(
                  threads: unreadThreads,
                  currentUserId: currentUserId,
                  onOpenThread: (threadId) {
                    repository.markThreadRead(threadId);
                    context.push(AppRoutes.messagesThreadPath(threadId));
                  },
                ),
                InvitesSection(
                  invites: invites,
                  onOpenInvite: (invite) {
                    repository.markInviteRead(invite.inviteId);
                    context.go(
                      AppRoutes.invitePath(
                        groupId: invite.groupId,
                        inviteId: invite.inviteId,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
