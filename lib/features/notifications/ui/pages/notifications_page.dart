import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

import '../../../messaging/repositories/chat_repository.dart';
import '../../../../modules/auth/repositories/auth_repository.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../logic/notifications_controller.dart';
import '../../models/invite_notification_entity.dart';
import '../../repositories/invite_notifications_repository.dart';
import '../widgets/invites_section.dart';
import '../widgets/unread_threads_section.dart';
import '../../../../modules/groups/repositories/groups_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final GroupsRepository groupsRepository;
  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final LikedMusiciansCubit likedMusiciansCubit;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      groupsRepository: groupsRepository,
      chatRepository: chatRepository,
      inviteNotificationsRepository: inviteNotificationsRepository,
      likedMusiciansCubit: likedMusiciansCubit,
      child: _NotificationsView(
        chatRepository: chatRepository,
        inviteNotificationsRepository: inviteNotificationsRepository,
        authRepository: context.read<AuthRepository>(),
      ),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView({
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.authRepository,
  });

  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final AuthRepository authRepository;

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(
      chatRepository: widget.chatRepository,
      inviteRepository: widget.inviteNotificationsRepository,
      authRepository: widget.authRepository,
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
