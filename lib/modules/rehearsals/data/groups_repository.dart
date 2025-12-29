import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/group_membership_entity.dart';
import 'group_dtos.dart';
import 'rehearsals_repository_base.dart';

class GroupsRepository extends RehearsalsRepositoryBase {
  GroupsRepository({
    super.firestore,
    super.authRepository,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Stream<List<GroupMembershipEntity>> watchMyGroups() async* {
    yield* authRepository.idTokenChanges.asyncExpand((user) {
      if (user == null) {
        logFirestore('watchMyGroups skipped (no auth)');
        return Stream.value(const <GroupMembershipEntity>[]);
      }
      return Stream.fromFuture(requireMusicianUid()).asyncExpand((uid) {
        return _watchMyGroupsWithRetry(uid);
      });
    });
  }

  Stream<List<GroupMembershipEntity>> _watchMyGroupsWithRetry(String uid) async* {
    const maxAttempts = 5;
    var attempt = 0;
    while (true) {
      try {
        logFirestore('watchMyGroups query ownerId=$uid status=active');
        final stream = firestore
            .collectionGroup('members')
            .where('ownerId', isEqualTo: uid)
            .where('status', isEqualTo: 'active')
            .snapshots()
            .asyncMap((snapshot) => _processMembershipSnapshot(uid, snapshot));
        await for (final value
            in logStream('watchMyGroups snapshots', stream)) {
          yield value;
        }
        return;
      } catch (error) {
        attempt += 1;
        logFirestore('watchMyGroups retry $attempt after error: $error');
        if (attempt >= maxAttempts || !_isPermissionDenied(error)) {
          rethrow;
        }
        await authRepository.refreshIdToken();
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
  }

  Future<List<GroupMembershipEntity>> _processMembershipSnapshot(
    String uid,
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final rawMemberships = snapshot.docs
        .map((doc) => MembershipDoc.fromMemberDoc(doc))
        .where((m) => m.groupId.isNotEmpty)
        .toList();

    await _ensureCanonicalOwnerMemberships(uid, rawMemberships);

    final groupIds =
        rawMemberships.map((m) => m.groupId).toSet().toList()..sort();
    if (groupIds.isEmpty) {
      return const <GroupMembershipEntity>[];
    }

    final groupsById = await _fetchGroupsById(groupIds);

    final memberships = <GroupMembershipEntity>[];
    for (final membership in rawMemberships) {
      final group = groupsById[membership.groupId];
      if (group == null) continue;
      memberships.add(
        GroupMembershipEntity(
          groupId: membership.groupId,
          groupName: group.name,
          groupOwnerId: group.ownerId,
          role: membership.role,
        ),
      );
    }
    memberships.sort((a, b) => a.groupName.compareTo(b.groupName));
    return memberships;
  }

  bool _isPermissionDenied(Object error) {
    return error is FirebaseException && error.code == 'permission-denied';
  }

  Stream<String?> watchMyRole(String groupId) {
    final uid = requireUid();
    return members(groupId).doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return (data['role'] ?? '').toString();
    });
  }

  Stream<String> watchGroupName(String groupId) {
    return Stream.fromFuture(requireMusicianUid()).asyncExpand((_) {
      return groupDoc(groupId).snapshots().map((doc) {
        final data = doc.data() ?? <String, dynamic>{};
        final name = (data['name'] ?? '').toString();
        return name.isEmpty ? 'Grupo' : name;
      });
    });
  }

  Future<bool> isActiveMember(String groupId) async {
    final uid = await requireMusicianUid();
    logFirestore('isActiveMember groupId=$groupId uid=$uid');
    final doc = await members(groupId).doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data() ?? <String, dynamic>{};
    return (data['status'] ?? '').toString() == 'active';
  }

  Future<String> createGroup({
    required String name,
    String? genre,
    String? link1,
    String? link2,
    Uint8List? photoBytes,
    String? photoFileExtension,
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('createGroup ownerId=$uid name="${name.trim()}"');
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('El nombre del grupo es obligatorio.');
    }

    final newGroupDoc = groups().doc();
    final memberDoc = members(newGroupDoc.id).doc(uid);
    final batch = firestore.batch();
    batch.set(newGroupDoc, {
      'groupId': newGroupDoc.id,
      'name': trimmedName,
      'ownerId': uid,
      'genre': (genre ?? '').trim(),
      'link1': (link1 ?? '').trim(),
      'link2': (link2 ?? '').trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      memberDoc,
      _memberData(uid: uid, role: 'owner', addedBy: uid),
    );
    await logFuture('createGroup commit', batch.commit());

    final bytes = photoBytes;
    if (bytes != null && bytes.isNotEmpty) {
      final ext = _normalizeImageExtension(photoFileExtension);
      final ref = _storage
          .ref()
          .child('groups')
          .child(newGroupDoc.id)
          .child('photo.$ext');
      final metadata = SettableMetadata(contentType: 'image/$ext');
      await ref.putData(bytes, metadata);
      final photoUrl = await ref.getDownloadURL();
      await newGroupDoc.set({'photoUrl': photoUrl}, SetOptions(merge: true));
    }

    return newGroupDoc.id;
  }

  Future<void> deleteGroup({required String groupId}) async {
    final uid = requireUid();
    logFirestore('deleteGroup groupId=$groupId uid=$uid');
    final groupRef = groupDoc(groupId);
    final groupSnap = await groupRef.get();
    final group = groupSnap.data() ?? <String, dynamic>{};
    final ownerId = (group['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      throw Exception('Solo el dueño puede eliminar el grupo.');
    }

    final batch = firestore.batch();

    // Delete all members of the group
    final membersSnap = await members(groupId).get();
    for (final doc in membersSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete the group itself
    batch.delete(groupRef);

    await logFuture('deleteGroup commit', batch.commit());
  }

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

  Future<Map<String, GroupDoc>> _fetchGroupsById(List<String> groupIds) async {
    // Fetching with a `whereIn(documentId)` query can fail the whole request if
    // any single group is not readable due to security rules. Fetching
    // individually lets us keep the readable ones.
    final futures = groupIds.map((groupId) async {
      try {
        final snap = await groupDoc(groupId).get();
        if (!snap.exists) return null;
        return GroupDoc.fromGroupDoc(snap);
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    final map = <String, GroupDoc>{};
    for (final group in results) {
      if (group == null || group.id.isEmpty) continue;
      map[group.id] = group;
    }
    return map;
  }

  Future<void> _ensureCanonicalOwnerMemberships(
    String uid,
    List<MembershipDoc> memberships,
  ) async {
    final ownerGroupIds =
        memberships
            .where((membership) => membership.role == 'owner')
            .map((membership) => membership.groupId)
            .where((groupId) => groupId.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    if (ownerGroupIds.isEmpty) return;

    await Future.wait(
      ownerGroupIds.map((groupId) async {
        final ref = members(groupId).doc(uid);
        final snap = await ref.get();
        if (snap.exists) return;
        await ref.set(_memberData(uid: uid, role: 'owner', addedBy: uid));
      }),
    );
  }
}

Map<String, dynamic> _memberData({
  required String uid,
  required String role,
  required String addedBy,
  String? inviteId,
}) {
  return {
    'userId': uid,
    'ownerId': uid,
    'role': role,
    'status': 'active',
    'createdAt': FieldValue.serverTimestamp(),
    'addedBy': addedBy,
    if (inviteId != null) 'inviteId': inviteId,
  };
}

String _normalizeImageExtension(String? input) {
  final normalized = (input ?? '').toLowerCase().replaceAll('.', '');
  if (normalized.isEmpty) return 'jpeg';
  switch (normalized) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
    case 'gif':
    case 'webp':
      return normalized;
    default:
      return 'jpeg';
  }
}
