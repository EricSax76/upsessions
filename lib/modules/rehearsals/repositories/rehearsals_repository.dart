import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rehearsal_entity.dart';
import 'rehearsals_repository_base.dart';

class RehearsalsRepository extends RehearsalsRepositoryBase {
  RehearsalsRepository({
    required super.firestore,
    required super.authRepository,
  });

  Future<List<RehearsalEntity>> getMyRehearsals() async {
    final uid = await requireMusicianUid();
    logFirestore('getMyRehearsals uid=$uid');
    final groupIds = await _fetchActiveGroupIds(uid);
    if (groupIds.isEmpty) {
      return [];
    }
    return _getMyRehearsalsByMembership(groupIds);
  }

  /// Returns the user IDs of all members in a group.
  Future<List<String>> getGroupMemberIds(String groupId) async {
    logFirestore('getGroupMemberIds groupId=$groupId');
    final snapshot = await logFuture(
      'getGroupMemberIds get',
      members(groupId).get(),
    );
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<RehearsalEntity>> getRehearsals(String groupId) async {
    await requireMusicianUid();
    logFirestore('getRehearsals groupId=$groupId');
    final snapshot = await logFuture(
      'getRehearsals get',
      rehearsals(groupId).orderBy('startsAt', descending: false).get(),
    );
    return snapshot.docs.map((doc) => _mapRehearsal(doc, groupId)).toList();
  }

  Stream<List<RehearsalEntity>> watchRehearsals(String groupId) async* {
    await requireMusicianUid();
    logFirestore('watchRehearsals groupId=$groupId');
    final stream = rehearsals(groupId)
        .orderBy('startsAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _mapRehearsal(doc, groupId)).toList(),
        );
    yield* logStream('watchRehearsals snapshots', stream);
  }

  Stream<RehearsalEntity?> watchRehearsal({
    required String groupId,
    required String rehearsalId,
  }) {
    return Stream.fromFuture(requireMusicianUid()).asyncExpand((_) {
      logFirestore('watchRehearsal groupId=$groupId rehearsalId=$rehearsalId');
      final stream = rehearsals(groupId).doc(rehearsalId).snapshots().map((
        doc,
      ) {
        if (!doc.exists) return null;
        final data = doc.data() ?? <String, dynamic>{};
        return _mapRehearsalFromMap(doc.id, data, groupId);
      });
      return logStream('watchRehearsal snapshots', stream);
    });
  }

  Future<String> createRehearsal({
    required String groupId,
    required DateTime startsAt,
    DateTime? endsAt,
    String location = '',
    String notes = '',
    String? title,
    String? setlistId,
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('createRehearsal groupId=$groupId uid=$uid');
    final doc = rehearsals(groupId).doc();
    await logFuture(
      'createRehearsal set',
      doc.set({
        'groupId': groupId,
        'startsAt': Timestamp.fromDate(startsAt),
        'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt),
        'location': location.trim(),
        'notes': notes.trim(),
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        // Normativa
        'title': title?.trim(),
        'setlistId': setlistId,
        'attendees': const <String>[],
        'isConfirmed': false,
        'canceledAt': null,
        'cancellationReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
    return doc.id;
  }

  Future<void> deleteRehearsal({
    required String groupId,
    required String rehearsalId,
  }) async {
    final uid = requireUid();
    logFirestore(
      'deleteRehearsal groupId=$groupId rehearsalId=$rehearsalId uid=$uid',
    );

    final groupSnap = await groupDoc(groupId).get();
    final group = groupSnap.data() ?? <String, dynamic>{};
    final ownerId = (group['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      throw Exception('Solo el dueño puede eliminar el ensayo.');
    }

    final batch = firestore.batch();
    final setlistSnap = await setlist(groupId, rehearsalId).get();
    for (final doc in setlistSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(rehearsals(groupId).doc(rehearsalId));
    await logFuture('deleteRehearsal commit', batch.commit());
  }

  Future<void> updateRehearsal({
    required String groupId,
    required String rehearsalId,
    required DateTime startsAt,
    DateTime? endsAt,
    String location = '',
    String notes = '',
    String? title,
    String? setlistId,
  }) async {
    await requireMusicianUid();
    logFirestore('updateRehearsal groupId=$groupId rehearsalId=$rehearsalId');
    await logFuture(
      'updateRehearsal update',
      rehearsals(groupId).doc(rehearsalId).update({
        'groupId': groupId,
        'startsAt': Timestamp.fromDate(startsAt),
        'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt),
        'location': location.trim(),
        'notes': notes.trim(),
        if (title != null) 'title': title.trim(),
        'setlistId': ?setlistId,
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  Future<void> updateRehearsalBooking({
    required String groupId,
    required String rehearsalId,
    required String bookingId,
  }) async {
    await requireMusicianUid();
    logFirestore(
      'updateRehearsalBooking groupId=$groupId rehearsalId=$rehearsalId bookingId=$bookingId',
    );
    await logFuture(
      'updateRehearsalBooking update',
      rehearsals(groupId).doc(rehearsalId).update({'bookingId': bookingId}),
    );
  }

  RehearsalEntity _mapRehearsal(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String groupId,
  ) {
    return _mapRehearsalFromMap(doc.id, doc.data(), groupId);
  }

  Future<List<String>> _fetchActiveGroupIds(String ownerId) async {
    final memberships = await logFuture(
      'getMyRehearsals memberships ownerId=$ownerId',
      firestore
          .collectionGroup('members')
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: 'active')
          .get(),
    );
    return memberships.docs
        .map((doc) => doc.reference.parent.parent?.id ?? '')
        .where((groupId) => groupId.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<RehearsalEntity>> _getMyRehearsalsByMembership(
    List<String> groupIds,
  ) async {
    try {
      final indexed = await _getMyRehearsalsByGroupIndex(groupIds);
      // Legacy rehearsals might miss `groupId` until backfill is complete.
      if (indexed.isNotEmpty) {
        return indexed;
      }
    } on FirebaseException catch (error) {
      logFirestore(
        'getMyRehearsals indexed query unavailable (${error.code}), using group fan-out fallback',
      );
    }

    return _getMyRehearsalsByGroupFanOut(groupIds);
  }

  Future<List<RehearsalEntity>> _getMyRehearsalsByGroupIndex(
    List<String> groupIds,
  ) async {
    const maxResults = 100;
    final chunks = _chunk(groupIds, 10);
    final rawPerChunkLimit = (maxResults / chunks.length).ceil();
    final perChunkLimit = rawPerChunkLimit < 10 ? 10 : rawPerChunkLimit;

    final chunkResults = await Future.wait(
      chunks.map((chunk) async {
        final snapshot = await logFuture(
          'getMyRehearsals indexed chunk=${chunk.length}',
          firestore
              .collectionGroup('rehearsals')
              .where('groupId', whereIn: chunk)
              .orderBy('startsAt', descending: false)
              .limit(perChunkLimit)
              .get(),
        );
        return snapshot.docs
            .map((doc) {
              final data = doc.data();
              final groupIdFromData = (data['groupId'] ?? '').toString().trim();
              final groupId = groupIdFromData.isNotEmpty
                  ? groupIdFromData
                  : (doc.reference.parent.parent?.id ?? '');
              if (groupId.isEmpty) return null;
              return _mapRehearsalFromMap(doc.id, data, groupId);
            })
            .whereType<RehearsalEntity>()
            .toList();
      }),
    );

    // Hard cap result size to prevent oversized payloads.
    final merged = chunkResults.expand((items) => items).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    if (merged.length > maxResults) {
      return merged.take(maxResults).toList();
    }
    return merged;
  }

  Future<List<RehearsalEntity>> _getMyRehearsalsByGroupFanOut(
    List<String> groupIds,
  ) async {
    final cappedGroupIds = groupIds.take(20).toList();

    final byGroup = await Future.wait(
      cappedGroupIds.map((groupId) async {
        try {
          final snapshot = await logFuture(
            'getMyRehearsals fallback group=$groupId',
            rehearsals(
              groupId,
            ).orderBy('startsAt', descending: false).limit(50).get(),
          );
          return snapshot.docs
              .map((doc) => _mapRehearsal(doc, groupId))
              .toList();
        } catch (error) {
          logFirestore(
            'getMyRehearsals fallback skip group=$groupId error=$error',
          );
          return const <RehearsalEntity>[];
        }
      }),
    );

    final rehearsalsList = byGroup.expand((items) => items).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return rehearsalsList;
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

  RehearsalEntity _mapRehearsalFromMap(
    String id,
    Map<String, dynamic> data,
    String groupId,
  ) {
    final startsAt =
        (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endsAt = (data['endsAt'] as Timestamp?)?.toDate();
    return RehearsalEntity(
      id: id,
      groupId: groupId,
      startsAt: startsAt,
      endsAt: endsAt,
      location: (data['location'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
      bookingId: data['bookingId'] as String?,
      // Normativa
      title: data['title'] as String?,
      setlistId: data['setlistId'] as String?,
      attendees: List<String>.from(data['attendees'] ?? []),
      isConfirmed: data['isConfirmed'] as bool? ?? false,
      canceledAt: (data['canceledAt'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
