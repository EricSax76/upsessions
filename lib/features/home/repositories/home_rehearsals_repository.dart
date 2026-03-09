import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';

import 'home_repository_mappers.dart';

class HomeRehearsalsRepository {
  HomeRehearsalsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _firestore = firestore,
       _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  Future<List<RehearsalEntity>> fetchUpcomingRehearsals({int limit = 5}) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return [];
    }
    final groupIds = await _fetchActiveGroupIds(ownerId: user.id);
    if (groupIds.isEmpty) {
      return [];
    }
    final now = Timestamp.fromDate(DateTime.now());
    try {
      final indexed = await _fetchUpcomingByGroupIndex(
        groupIds: groupIds,
        now: now,
        limit: limit,
      );
      if (indexed.isNotEmpty) {
        return indexed;
      }
    } on FirebaseException {
      // Fall back to per-group fan-out if indexes are not ready yet.
    }

    return _fetchUpcomingRehearsalsByMembershipLookup(
      groupIds: groupIds,
      now: now,
      limit: limit,
    );
  }

  Future<List<String>> _fetchActiveGroupIds({required String ownerId}) async {
    final memberships = await _firestore
        .collectionGroup('members')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'active')
        .get();
    return memberships.docs
        .map((doc) => doc.reference.parent.parent?.id ?? '')
        .where((groupId) => groupId.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<RehearsalEntity>> _fetchUpcomingByGroupIndex({
    required List<String> groupIds,
    required Timestamp now,
    required int limit,
  }) async {
    final chunks = _chunk(groupIds, 10);
    final rawPerChunkLimit = (limit / chunks.length).ceil() + 1;
    final perChunkLimit = rawPerChunkLimit < 3 ? 3 : rawPerChunkLimit;

    final chunkResults = await Future.wait(
      chunks.map((chunk) async {
        final snapshot = await _firestore
            .collectionGroup('rehearsals')
            .where('groupId', whereIn: chunk)
            .where('startsAt', isGreaterThanOrEqualTo: now)
            .orderBy('startsAt')
            .limit(perChunkLimit)
            .get();
        return snapshot.docs
            .map((doc) {
              final groupIdFromData = (doc.data()['groupId'] ?? '')
                  .toString()
                  .trim();
              final groupId = groupIdFromData.isNotEmpty
                  ? groupIdFromData
                  : (doc.reference.parent.parent?.id ?? '');
              if (groupId.isEmpty) return null;
              return HomeRepositoryMappers.rehearsalFromDoc(
                doc,
                groupId: groupId,
              );
            })
            .whereType<RehearsalEntity>()
            .toList();
      }),
    );

    final allRehearsals = chunkResults.expand((x) => x).toList();
    if (allRehearsals.isEmpty) {
      return [];
    }
    allRehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return allRehearsals.take(limit).toList();
  }

  Future<List<RehearsalEntity>> _fetchUpcomingRehearsalsByMembershipLookup({
    required List<String> groupIds,
    required Timestamp now,
    required int limit,
  }) async {
    if (groupIds.isEmpty) {
      return [];
    }
    final cappedGroupIds = groupIds.take(20).toList();

    final futures = cappedGroupIds.map((groupId) async {
      try {
        final snapshot = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('rehearsals')
            .where('startsAt', isGreaterThanOrEqualTo: now)
            .orderBy('startsAt')
            .limit(limit)
            .get();
        if (snapshot.docs.isEmpty) {
          return <RehearsalEntity>[];
        }
        return snapshot.docs
            .map(
              (doc) =>
                  HomeRepositoryMappers.rehearsalFromDoc(doc, groupId: groupId),
            )
            .toList();
      } catch (_) {
        return <RehearsalEntity>[];
      }
    });

    final results = await Future.wait(futures);
    final allRehearsals = results.expand((x) => x).toList();
    if (allRehearsals.isEmpty) {
      return [];
    }

    allRehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return allRehearsals.take(limit).toList();
  }

  List<List<String>> _chunk(List<String> input, int size) {
    final chunks = <List<String>>[];
    for (var i = 0; i < input.length; i += size) {
      chunks.add(
        input.sublist(i, i + size > input.length ? input.length : i + size),
      );
    }
    return chunks;
  }
}
