import 'package:flutter/foundation.dart';

import '../../../messaging/models/chat_thread.dart';
import '../../models/invite_notification_entity.dart';

@immutable
class NotificationsViewModel {
  const NotificationsViewModel({
    required this.unreadThreads,
    required this.invites,
    required this.currentUserId,
  });

  const NotificationsViewModel.empty()
    : unreadThreads = const [],
      invites = const [],
      currentUserId = '';

  final List<ChatThread> unreadThreads;
  final List<InviteNotificationEntity> invites;
  final String currentUserId;

  bool get isEmpty => unreadThreads.isEmpty && invites.isEmpty;
}
