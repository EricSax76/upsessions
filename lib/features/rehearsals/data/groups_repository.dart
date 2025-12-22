import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/group_membership_entity.dart';
import 'rehearsals_repository_base.dart';

class GroupsRepository extends RehearsalsRepositoryBase {
  GroupsRepository({super.firestore, super.authRepository});

  Stream<List<GroupMembershipEntity>> watchMyGroups() async* {
    final uid = await requireMusicianUid();
    yield* firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snapshot) async {
          final rawMemberships = snapshot.docs
              .map((doc) => _MembershipDoc.fromMemberDoc(doc))
              .where((m) => m.groupId.isNotEmpty)
              .toList();

          final groupIds = rawMemberships.map((m) => m.groupId).toSet().toList()
            ..sort();
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
        });
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

  Future<String> createGroup({required String name}) async {
    final uid = await requireMusicianUid();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('El nombre del grupo es obligatorio.');
    }

    final newGroupDoc = groups().doc();
    final memberDoc = members(newGroupDoc.id).doc(uid);
    final batch = firestore.batch();
    batch.set(newGroupDoc, {
      'name': trimmedName,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(memberDoc, {
      'userId': uid,
      'role': 'owner',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'addedBy': uid,
    });
    await batch.commit();
    return newGroupDoc.id;
  }

  Future<void> deleteGroup({required String groupId}) async {
    final uid = requireUid();
    final groupRef = groupDoc(groupId);
    final groupSnap = await groupRef.get();
    final group = groupSnap.data() ?? <String, dynamic>{};
    final ownerId = (group['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      throw Exception('Solo el dueño puede eliminar el grupo.');
    }

    final batch = firestore.batch();
    batch.delete(groupRef);
    // TODO: delete members and other subcollections
    await batch.commit();
  }

  Future<String> createInvite({
    required String groupId,
    required String targetUid,
    Duration ttl = const Duration(days: 7),
  }) async {
    final uid = requireUid();
    if (targetUid.trim().isEmpty) {
      throw Exception('El usuario destino no es válido.');
    }
    final doc = invites(groupId).doc();
    await doc.set({
      'targetUid': targetUid.trim(),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(ttl)),
      'status': 'active',
      'usedBy': null,
      'usedAt': null,
    });
    return doc.id;
  }

  Future<void> acceptInvite({
    required String groupId,
    required String inviteId,
  }) async {
    final uid = await requireMusicianUid();
    final inviteRef = invites(groupId).doc(inviteId);
    final memberRef = members(groupId).doc(uid);

    await firestore.runTransaction((tx) async {
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
        tx.set(memberRef, {
          'userId': uid,
          'role': 'member',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'addedBy': (invite['createdBy'] ?? '').toString(),
          'inviteId': inviteId,
        });
      } else {
        final existing = memberSnap.data() ?? <String, dynamic>{};
        final existingUserId = (existing['userId'] ?? '').toString();
        if (existingUserId != uid) {
          tx.update(memberRef, {'userId': uid});
        }
      }

      tx.update(inviteRef, {
        'status': 'used',
        'usedBy': uid,
        'usedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Map<String, _GroupDoc>> _fetchGroupsById(List<String> groupIds) async {
    final chunks = <List<String>>[];
    for (var i = 0; i < groupIds.length; i += 10) {
      chunks.add(groupIds.sublist(i, (i + 10).clamp(0, groupIds.length)));
    }
    final futures = chunks.map((chunk) async {
      final snapshot = await groups()
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      return snapshot.docs
          .map((doc) => _GroupDoc.fromGroupDoc(doc))
          .where((g) => g.id.isNotEmpty)
          .toList();
    }).toList();

    final results = await Future.wait(futures);
    final map = <String, _GroupDoc>{};
    for (final list in results) {
      for (final group in list) {
        map[group.id] = group;
      }
    }
    return map;
  }
}

class _GroupDoc {
  const _GroupDoc({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  final String id;
  final String name;
  final String ownerId;

  factory _GroupDoc.fromGroupDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return _GroupDoc(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      ownerId: (data['ownerId'] ?? '').toString(),
    );
  }
}

class _MembershipDoc {
  const _MembershipDoc({required this.groupId, required this.role});

  final String groupId;
  final String role;

  factory _MembershipDoc.fromMemberDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final groupId = doc.reference.parent.parent?.id ?? '';
    final data = doc.data();
    return _MembershipDoc(
      groupId: groupId,
      role: (data['role'] ?? 'member').toString(),
    );
  }
}
