import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/setlist_item_entity.dart';
import 'rehearsals_repository_base.dart';

class SetlistRepository extends RehearsalsRepositoryBase {
  Stream<List<SetlistItemEntity>> watchSetlist({
    required String groupId,
    required String rehearsalId,
  }) {
    requireUid();
    logFirestore('watchSetlist groupId=$groupId rehearsalId=$rehearsalId');
    final stream = setlist(groupId, rehearsalId)
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapSetlistItem).toList());
    return logStream('watchSetlist snapshots', stream);
  }

  Future<String> addSetlistItem({
    required String groupId,
    required String rehearsalId,
    required int order,
    String? songId,
    String? songTitle,
    String keySignature = '',
    int? tempoBpm,
    String notes = '',
  }) async {
    requireUid();
    logFirestore('addSetlistItem groupId=$groupId rehearsalId=$rehearsalId');
    final doc = setlist(groupId, rehearsalId).doc();
    await logFuture(
      'addSetlistItem set',
      doc.set({
        'order': order,
        'songId': songId,
        'songTitle': songTitle?.trim(),
        'key': keySignature.trim(),
        'tempoBpm': tempoBpm,
        'notes': notes.trim(),
      }),
    );
    return doc.id;
  }

  Future<void> deleteSetlistItem({
    required String groupId,
    required String rehearsalId,
    required String itemId,
  }) async {
    requireUid();
    logFirestore('deleteSetlistItem groupId=$groupId rehearsalId=$rehearsalId itemId=$itemId');
    await logFuture(
      'deleteSetlistItem delete',
      setlist(groupId, rehearsalId).doc(itemId).delete(),
    );
  }

  SetlistItemEntity _mapSetlistItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return SetlistItemEntity(
      id: doc.id,
      order: (data['order'] as num?)?.toInt() ?? 0,
      songId: (data['songId'] as String?)?.trim(),
      songTitle: (data['songTitle'] as String?)?.trim(),
      keySignature: (data['key'] ?? '').toString(),
      tempoBpm: (data['tempoBpm'] as num?)?.toInt(),
      notes: (data['notes'] ?? '').toString(),
    );
  }
}
