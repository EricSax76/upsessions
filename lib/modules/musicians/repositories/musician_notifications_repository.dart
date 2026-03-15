import 'package:upsessions/features/messaging/models/chat_thread.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/notifications/models/invite_notification_entity.dart';
import 'package:upsessions/modules/notifications/repositories/invite_notifications_repository.dart';

/// Role-specific notifications gateway for musician sessions.
///
/// Keeps musician notification orchestration in the `musicians` module while
/// reusing the underlying messaging and invite repositories.
class MusicianNotificationsRepository {
  MusicianNotificationsRepository({
    required ChatRepository chatRepository,
    required InviteNotificationsRepository inviteNotificationsRepository,
  }) : _chatRepository = chatRepository,
       _inviteNotificationsRepository = inviteNotificationsRepository;

  final ChatRepository _chatRepository;
  final InviteNotificationsRepository _inviteNotificationsRepository;

  Stream<List<ChatThread>> watchUnreadThreads() {
    return _chatRepository.watchThreads().map((threads) {
      return threads
          .where((thread) => thread.unreadCount > 0)
          .toList(growable: false);
    });
  }

  Stream<int> watchUnreadChatsCount() {
    return _chatRepository.watchUnreadTotal();
  }

  Stream<List<InviteNotificationEntity>> watchInvites() {
    return _inviteNotificationsRepository.watchMyInvites();
  }

  Stream<int> watchUnreadInvitesCount() {
    return watchInvites().map((invites) {
      return invites.where((invite) => !invite.read).length;
    });
  }

  void markThreadRead(String threadId) {
    _chatRepository.markThreadRead(threadId);
  }

  Future<void> markInviteRead(String inviteId) {
    return _inviteNotificationsRepository.markRead(inviteId);
  }
}
