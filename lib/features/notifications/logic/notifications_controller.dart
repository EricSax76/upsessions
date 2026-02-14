import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../messaging/models/chat_thread.dart';
import '../../messaging/repositories/chat_repository.dart';
import '../../../modules/auth/repositories/auth_repository.dart';
import '../models/invite_notification_entity.dart';
import '../repositories/invite_notifications_repository.dart';
import '../ui/models/notifications_view_model.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required ChatRepository chatRepository,
    required InviteNotificationsRepository inviteRepository,
    required AuthRepository authRepository,
  })  : _chatRepository = chatRepository,
        _inviteRepository = inviteRepository {
    _currentUserId = authRepository.currentUser?.id ?? '';
    _subscribe();
  }

  final ChatRepository _chatRepository;
  final InviteNotificationsRepository _inviteRepository;

  bool _isDisposed = false;

  String _currentUserId = '';
  bool _loading = true;
  String? _error;
  List<ChatThread> _unreadThreads = const [];
  List<InviteNotificationEntity> _invites = const [];

  StreamSubscription<List<ChatThread>>? _threadsSub;
  StreamSubscription<List<InviteNotificationEntity>>? _invitesSub;

  // ── Public getters ─────────────────────────

  bool get loading => _loading;
  String? get error => _error;

  NotificationsViewModel get viewModel => NotificationsViewModel(
    unreadThreads: _unreadThreads,
    invites: _invites,
    currentUserId: _currentUserId,
  );

  // ── Actions ────────────────────────────────

  void openThread(String threadId) {
    _chatRepository.markThreadRead(threadId);
  }

  Future<void> openInvite(InviteNotificationEntity invite) async {
    await _inviteRepository.markRead(invite.inviteId);
  }

  // ── Stream subscriptions ───────────────────

  void _subscribe() {
    _threadsSub = _chatRepository.watchThreads().listen(
      (threads) {
        _unreadThreads = threads
            .where((thread) => thread.unreadCount > 0)
            .toList(growable: false);
        _checkLoaded();
        _safeNotify();
      },
      onError: (Object e) {
        _error = 'Error cargando hilos: $e';
        _loading = false;
        _safeNotify();
      },
    );

    _invitesSub = _inviteRepository.watchMyInvites().listen(
      (invites) {
        _invites = invites;
        _checkLoaded();
        _safeNotify();
      },
      onError: (Object e) {
        _error = 'Error cargando invitaciones: $e';
        _loading = false;
        _safeNotify();
      },
    );
  }

  bool _threadsLoaded = false;
  bool _invitesLoaded = false;

  void _checkLoaded() {
    if (!_threadsLoaded && _threadsSub != null) _threadsLoaded = true;
    if (!_invitesLoaded && _invitesSub != null) _invitesLoaded = true;
    if (_threadsLoaded && _invitesLoaded) _loading = false;
  }

  // ── Internal ───────────────────────────────

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _threadsSub?.cancel();
    _invitesSub?.cancel();
    super.dispose();
  }
}
