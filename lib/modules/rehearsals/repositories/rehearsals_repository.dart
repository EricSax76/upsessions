import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rehearsal_entity.dart';
import 'rehearsals_repository_base.dart';

class RehearsalsRepository extends RehearsalsRepositoryBase {
  Future<List<RehearsalEntity>> getMyRehearsals() async {
    await requireMusicianUid();
    logFirestore('getMyRehearsals');
    final snapshot = await logFuture(
      'getMyRehearsals get',
      firestore.collectionGroup('rehearsals').orderBy('startsAt').get(),
    );
    return snapshot.docs
        .map((doc) {
          final groupId = doc.reference.parent.parent?.id ?? '';
          if (groupId.isEmpty) return null;
          return _mapRehearsalFromMap(doc.id, doc.data(), groupId);
        })
        .whereType<RehearsalEntity>()
        .toList();
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
  }) async {
    final uid = await requireMusicianUid();
    logFirestore('createRehearsal groupId=$groupId uid=$uid');
    final doc = rehearsals(groupId).doc();
    await logFuture(
      'createRehearsal set',
      doc.set({
        'startsAt': Timestamp.fromDate(startsAt),
        'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt),
        'location': location.trim(),
        'notes': notes.trim(),
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
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
  }) async {
    await requireMusicianUid();
    logFirestore('updateRehearsal groupId=$groupId rehearsalId=$rehearsalId');
    await logFuture(
      'updateRehearsal update',
      rehearsals(groupId).doc(rehearsalId).update({
        'startsAt': Timestamp.fromDate(startsAt),
        'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt),
        'location': location.trim(),
        'notes': notes.trim(),
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
    );
  }
}
