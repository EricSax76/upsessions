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
    final now = Timestamp.fromDate(DateTime.now());
    try {
      final snapshot = await _firestore
          .collectionGroup('rehearsals')
          .where('startsAt', isGreaterThanOrEqualTo: now)
          .orderBy('startsAt')
          .limit(limit)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) {
              final groupId = doc.reference.parent.parent?.id ?? '';
              if (groupId.isEmpty) return null;
              return HomeRepositoryMappers.rehearsalFromDoc(
                doc,
                groupId: groupId,
              );
            })
            .whereType<RehearsalEntity>()
            .toList();
      }
      return [];
    } on FirebaseException {
      return _fetchUpcomingRehearsalsByMembershipLookup(
        ownerId: user.id,
        now: now,
        limit: limit,
      );
    }
  }

  Future<List<RehearsalEntity>> _fetchUpcomingRehearsalsByMembershipLookup({
    required String ownerId,
    required Timestamp now,
    required int limit,
  }) async {
    final memberships = await _firestore
        .collectionGroup('members')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'active')
        .get();
    final groupIds = memberships.docs
        .map((doc) => doc.reference.parent.parent?.id ?? '')
        .where((groupId) => groupId.isNotEmpty)
        .toSet()
        .toList();
    if (groupIds.isEmpty) {
      return [];
    }

    final futures = groupIds.map((groupId) async {
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
}
