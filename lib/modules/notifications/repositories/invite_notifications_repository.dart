import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../modules/rehearsals/repositories/rehearsals_repository_base.dart';
import '../models/invite_notification_entity.dart';

class InviteNotificationsRepository extends RehearsalsRepositoryBase {
  InviteNotificationsRepository({
    required super.firestore,
    required super.authRepository,
  });

  Stream<List<InviteNotificationEntity>>? _sharedStream;
  StreamController<List<InviteNotificationEntity>>? _controller;
  StreamSubscription? _sourceSubscription;

  CollectionReference<Map<String, dynamic>> _invitesRef(String uid) {
    return firestore.collection('musicians').doc(uid).collection('invites');
  }

  /// Returns a shared broadcast stream so multiple listeners reuse a single
  /// Firestore snapshot subscription. The underlying listener is torn down
  /// automatically when the last consumer cancels.
  Stream<List<InviteNotificationEntity>> watchMyInvites() {
    if (_controller != null && !_controller!.isClosed) {
      return _sharedStream!;
    }

    _controller = StreamController<List<InviteNotificationEntity>>.broadcast(
      onCancel: _tearDown,
    );
    _sharedStream = _controller!.stream;

    _sourceSubscription = authRepository.idTokenChanges.asyncExpand((user) {
      if (user == null) {
        return Stream.value(const <InviteNotificationEntity>[]);
      }
      final uid = user.id;
      final stream = _invitesRef(uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(InviteNotificationEntity.fromDoc)
                .where((invite) => invite.groupId.isNotEmpty)
                .toList();
          });
      return logStream('watchMyInvites snapshots', stream);
    }).listen(
      (data) {
        if (!_controller!.isClosed) _controller!.add(data);
      },
      onError: (Object e, StackTrace s) {
        if (!_controller!.isClosed) _controller!.addError(e, s);
      },
    );

    return _sharedStream!;
  }

  void _tearDown() {
    _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _controller?.close();
    _controller = null;
    _sharedStream = null;
  }

  Future<void> markRead(String inviteId) async {
    final uid = requireUid();
    await logFuture(
      'markInviteRead',
      _invitesRef(uid).doc(inviteId).set({
        'read': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  Future<void> updateStatus(String inviteId, String status) async {
    final uid = requireUid();
    await logFuture(
      'updateInviteStatus',
      _invitesRef(uid).doc(inviteId).set({
        'status': status,
        'read': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }
}
