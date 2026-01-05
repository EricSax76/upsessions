import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/notifications/models/invite_notification_entity.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';

class SmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmAppBar({super.key, this.bottom, this.showMenuButton = false});

  final PreferredSizeWidget? bottom;
  final bool showMenuButton;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + 12 + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final profile = state.profile;
        final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
        final displayName = user?.displayName ?? '';
        return AppBar(
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () => context.go(AppRoutes.userHome),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(Icons.home_outlined),
            ),
          ),
          bottom: bottom,
          leading: showMenuButton
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
          actions: [
            _NotificationsButton(
              onPressed: () => context.push(AppRoutes.notifications),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () => context.push(AppRoutes.account),
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _NotificationsButtonBody(onPressed: onPressed);
  }
}

class _NotificationsButtonBody extends StatefulWidget {
  const _NotificationsButtonBody({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_NotificationsButtonBody> createState() =>
      _NotificationsButtonBodyState();
}

class _NotificationsButtonBodyState extends State<_NotificationsButtonBody> {
  late final ChatRepository _chatRepository;
  late final InviteNotificationsRepository _invitesRepository;
  late final Stream<int> _unreadChatsStream;
  late final Stream<List<InviteNotificationEntity>> _invitesStream;

  @override
  void initState() {
    super.initState();
    _chatRepository = locate<ChatRepository>();
    _invitesRepository = locate<InviteNotificationsRepository>();
    _unreadChatsStream = _chatRepository.watchUnreadTotal();
    _invitesStream = _invitesRepository.watchMyInvites();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadChatsStream,
      builder: (context, unreadChatsSnapshot) {
        return StreamBuilder<List<InviteNotificationEntity>>(
          stream: _invitesStream,
          builder: (context, invitesSnapshot) {
            final invites =
                invitesSnapshot.data ?? const <InviteNotificationEntity>[];

            final unreadMessages = unreadChatsSnapshot.data ?? 0;
            final unreadInvites = invites
                .where((invite) => !invite.read)
                .length;
            final unreadTotal = unreadMessages + unreadInvites;

            return IconButton(
              onPressed: widget.onPressed,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none),
                  if (unreadTotal > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: _NotificationBadge(count: unreadTotal),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onError,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
