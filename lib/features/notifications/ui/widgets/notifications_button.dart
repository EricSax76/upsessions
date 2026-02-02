import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';

import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _NotificationsButtonBody(
      onPressed: () => context.push(AppRoutes.notifications),
    );
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
  final _totalUnreadController = StreamController<int>();
  final _subscriptions = <StreamSubscription>[];

  int _unreadChats = 0;
  int _unreadInvites = 0;

  @override
  void initState() {
    super.initState();
    _chatRepository = locate<ChatRepository>();
    _invitesRepository = locate<InviteNotificationsRepository>();

    _subscriptions.add(
      _chatRepository.watchUnreadTotal().listen((count) {
        _unreadChats = count;
        _emitTotal();
      }),
    );

    _subscriptions.add(
      _invitesRepository.watchMyInvites().listen((invites) {
        _unreadInvites = invites.where((i) => !i.read).length;
        _emitTotal();
      }),
    );
  }

  void _emitTotal() {
    if (!_totalUnreadController.isClosed) {
      _totalUnreadController.add(_unreadChats + _unreadInvites);
    }
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _totalUnreadController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _totalUnreadController.stream,
      initialData: 0,
      builder: (context, snapshot) {
        final unreadTotal = snapshot.data ?? 0;
        return IconButton(
          onPressed: widget.onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
