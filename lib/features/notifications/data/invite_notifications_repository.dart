import 'package:cloud_firestore/cloud_firestore.dart';

import '../../rehearsals/data/rehearsals_repository_base.dart';
import '../domain/invite_notification_entity.dart';

class InviteNotificationsRepository extends RehearsalsRepositoryBase {
  InviteNotificationsRepository({super.firestore, super.authRepository});

  CollectionReference<Map<String, dynamic>> _invitesRef(String uid) {
    return firestore.collection('musicians').doc(uid).collection('invites');
  }

  Stream<List<InviteNotificationEntity>> watchMyInvites() async* {
    yield* authRepository.idTokenChanges.asyncExpand((user) {
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
    });
  }

  Future<void> markRead(String inviteId) async {
    final uid = requireUid();
    await logFuture(
      'markInviteRead',
      _invitesRef(uid).doc(inviteId).set(
        {
          'read': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ),
    );
  }

  Future<void> updateStatus(String inviteId, String status) async {
    final uid = requireUid();
    await logFuture(
      'updateInviteStatus',
      _invitesRef(uid).doc(inviteId).set(
        {
          'status': status,
          'read': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ),
    );
  }
}
