part of 'groups_repository.dart';

mixin GroupsRepositoryMemberships on GroupsRepositoryBase {
  Stream<List<GroupMembershipEntity>> watchMyGroups() {
    // Return a fresh stream per consumer. This avoids stale subscriptions
    // when responsive layout switches rebuild pages and sidebars.
    return _buildWatchMyGroupsStream();
  }

  Stream<List<GroupMembershipEntity>> _buildWatchMyGroupsStream() {
    return authRepository.idTokenChanges.asyncExpand((user) {
      if (user == null) {
        logFirestore('watchMyGroups skipped (no auth)');
        return Stream.value(const <GroupMembershipEntity>[]);
      }
      return Stream.fromFuture(requireMusicianUid()).asyncExpand((uid) {
        return _watchMyGroupsWithRetry(uid);
      });
    });
  }

  Stream<List<GroupMembershipEntity>> _watchMyGroupsWithRetry(
    String uid,
  ) async* {
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
        await for (final value in logStream(
          'watchMyGroups snapshots',
          stream,
        )) {
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
          photoUrl: group.photoUrl,
        ),
      );
    }
    memberships.sort((a, b) => a.groupName.compareTo(b.groupName));
    return memberships;
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

  Stream<GroupDoc> watchGroup(String groupId) {
    return groupDoc(
      groupId,
    ).snapshots().map((doc) => GroupDoc.fromGroupDoc(doc));
  }

  Future<bool> isActiveMember(String groupId) async {
    final uid = await requireMusicianUid();
    logFirestore('isActiveMember groupId=$groupId uid=$uid');
    final doc = await members(groupId).doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data() ?? <String, dynamic>{};
    return (data['status'] ?? '').toString() == 'active';
  }

  bool _isPermissionDenied(Object error) {
    return error is FirebaseException && error.code == 'permission-denied';
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

  Stream<List<GroupMember>> watchGroupMembers(String groupId) {
    return members(groupId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap(_processGroupMembersSnapshot);
  }

  Future<List<GroupMember>> _processGroupMembersSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) return [];

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data();
      final uid = doc.id;
      final role = data['role']?.toString() ?? 'member';
      final status = data['status']?.toString() ?? 'active';

      try {
        final musicianDoc = await firestore
            .collection('musicians')
            .doc(uid)
            .get();
        final musicianData = musicianDoc.data() ?? {};

        return GroupMember(
          id: uid,
          name: musicianData['name']?.toString() ?? 'Musician',
          role: role,
          status: status,
          photoUrl: musicianData['photoUrl']?.toString(),
          instrument: musicianData['instrument']?.toString(),
        );
      } catch (e) {
        logFirestore('Error fetching musician profile for $uid: $e');
        return GroupMember(
          id: uid,
          name: 'Musician',
          role: role,
          status: status,
        );
      }
    });
    return Future.wait(futures);
  }
}
