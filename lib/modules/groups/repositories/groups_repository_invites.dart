part of 'groups_repository.dart';

mixin GroupsRepositoryInvites on GroupsRepositoryBase {
  Future<String> createInvite({
    required String groupId,
    required String targetUid,
    Duration ttl = const Duration(days: 7),
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('createInvite groupId=$groupId targetUid=$targetUid uid=$uid');
    if (targetUid.trim().isEmpty) {
      throw Exception('El usuario destino no es válido.');
    }
    final doc = invites(groupId).doc();
    await logFuture(
      'createInvite set',
      doc.set({
        'targetUid': targetUid.trim(),
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(ttl)),
        'status': 'active',
        'usedBy': null,
        'usedAt': null,
      }),
    );
    return doc.id;
  }

  Future<void> acceptInvite({
    required String groupId,
    required String inviteId,
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('acceptInvite groupId=$groupId inviteId=$inviteId uid=$uid');
    final inviteRef = invites(groupId).doc(inviteId);
    final memberRef = members(groupId).doc(uid);

    await logFuture(
      'acceptInvite transaction',
      firestore.runTransaction((tx) async {
        final inviteSnap = await tx.get(inviteRef);
        if (!inviteSnap.exists) {
          throw Exception('La invitación no existe.');
        }
        final invite = inviteSnap.data() ?? <String, dynamic>{};
        final targetUid = (invite['targetUid'] ?? '').toString();
        final status = (invite['status'] ?? '').toString();
        final expiresAt = invite['expiresAt'];
        final isExpired = expiresAt is Timestamp
            ? expiresAt.toDate().isBefore(DateTime.now())
            : true;

        if (targetUid != uid) {
          throw Exception('Esta invitación no es para tu cuenta.');
        }
        if (status != 'active') {
          throw Exception('La invitación ya fue utilizada o revocada.');
        }
        if (isExpired) {
          throw Exception('La invitación está vencida.');
        }

        final memberSnap = await tx.get(memberRef);
        if (!memberSnap.exists) {
          tx.set(
            memberRef,
            _memberData(
              uid: uid,
              role: 'member',
              addedBy: (invite['createdBy'] ?? '').toString(),
              inviteId: inviteId,
            ),
          );
        } else {
          final existing = memberSnap.data() ?? <String, dynamic>{};
          final existingUserId = (existing['userId'] ?? '').toString();
          if (existingUserId != uid) {
            tx.update(memberRef, {'userId': uid, 'ownerId': uid});
          }
        }

        tx.update(inviteRef, {
          'status': 'used',
          'usedBy': uid,
          'usedAt': FieldValue.serverTimestamp(),
        });
      }),
    );
  }
}
