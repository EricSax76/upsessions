import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../repositories/musician_notifications_repository.dart';
import '../../../notifications/cubits/notifications_controller.dart';
import '../../../notifications/models/invite_notification_entity.dart';
import '../../../notifications/ui/widgets/invites_section.dart';
import '../../../notifications/ui/widgets/unread_threads_section.dart';

class MusicianNotificationsPage extends StatefulWidget {
  const MusicianNotificationsPage({super.key, required this.repository});

  final MusicianNotificationsRepository repository;

  @override
  State<MusicianNotificationsPage> createState() =>
      _MusicianNotificationsPageState();
}

class _MusicianNotificationsPageState extends State<MusicianNotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(
      musicianNotificationsRepository: widget.repository,
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onOpenThread(String threadId) {
    _controller.openThread(threadId);
    context.push(AppRoutes.messagesThreadPath(threadId));
  }

  void _onOpenInvite(InviteNotificationEntity invite) {
    _controller.openInvite(invite);
    context.go(
      AppRoutes.invitePath(groupId: invite.groupId, inviteId: invite.inviteId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.error != null) {
          return Center(child: Text('Error: ${_controller.error}'));
        }

        if (_controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final vm = _controller.viewModel;

        if (vm.isEmpty) {
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
            UnreadThreadsSection(
              threads: vm.unreadThreads,
              currentUserId: vm.currentUserId,
              onOpenThread: _onOpenThread,
            ),
            InvitesSection(invites: vm.invites, onOpenInvite: _onOpenInvite),
          ],
        );
      },
    );
  }
}
