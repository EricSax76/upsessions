import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/widgets/theme_toggle_button.dart';
import 'package:upsessions/core/widgets/app_logo.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/notifications/models/invite_notification_entity.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

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
      builder: (context, authState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final user = authState.user;
            final profile = profileState.profile;
            final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
            final displayName = user?.displayName ?? '';
            return AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                shape: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                title: const AppLogo(label: 'UpSessions'),
                centerTitle: true,
                leading: showMenuButton
                    ? Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      )
                    : null,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ThemeToggleButton(),
                         _NotificationsButton(
                          onPressed: () => context.push(AppRoutes.notifications),
                         ),
                      ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(right: 16, left: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.push(AppRoutes.account),
                        borderRadius: BorderRadius.circular(24),
                        child: SmAvatar(
                          radius: 17, // Slightly larger visual with border
                          imageUrl: avatarUrl,
                          initials: displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '',
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: bottom,
              );
          },
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
            final unreadInvites =
                invites.where((invite) => !invite.read).length;
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
