import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/rehearsal_entity.dart';
import 'rehearsals_repository_base.dart';

class RehearsalsRepository extends RehearsalsRepositoryBase {
  Stream<List<RehearsalEntity>> watchRehearsals(String groupId) async* {
    await requireMusicianUid();
    yield* rehearsals(groupId)
        .orderBy('startsAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapRehearsal).toList());
  }

  Stream<RehearsalEntity?> watchRehearsal({
    required String groupId,
    required String rehearsalId,
  }) {
    return Stream.fromFuture(requireMusicianUid()).asyncExpand((_) {
      return rehearsals(groupId).doc(rehearsalId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() ?? <String, dynamic>{};
        return _mapRehearsalFromMap(doc.id, data);
      });
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
    final doc = rehearsals(groupId).doc();
    await doc.set({
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt),
      'location': location.trim(),
      'notes': notes.trim(),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
