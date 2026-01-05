import 'package:cloud_firestore/cloud_firestore.dart';

import '../cubits/rehearsal_entity.dart';
import 'rehearsals_repository_base.dart';

class RehearsalsRepository extends RehearsalsRepositoryBase {
  Stream<List<RehearsalEntity>> watchRehearsals(String groupId) async* {
    await requireMusicianUid();
    logFirestore('watchRehearsals groupId=$groupId');
    final stream = rehearsals(groupId)
        .orderBy('startsAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapRehearsal).toList());
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
        return _mapRehearsalFromMap(doc.id, data);
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

  RehearsalEntity _mapRehearsal(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return _mapRehearsalFromMap(doc.id, doc.data());
  }

  RehearsalEntity _mapRehearsalFromMap(String id, Map<String, dynamic> data) {
    final startsAt =
        (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endsAt = (data['endsAt'] as Timestamp?)?.toDate();
    return RehearsalEntity(
      id: id,
      startsAt: startsAt,
      endsAt: endsAt,
      location: (data['location'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
    );
  }
}
