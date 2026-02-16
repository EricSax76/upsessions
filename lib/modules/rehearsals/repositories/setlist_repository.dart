import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/setlist_item_entity.dart';
import 'rehearsals_repository_base.dart';

class SetlistRepository extends RehearsalsRepositoryBase {
  SetlistRepository({
    required super.firestore,
    required super.authRepository,
    required FirebaseStorage storage,
  }) : _storage = storage;

  final FirebaseStorage _storage;

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

  Future<List<SetlistItemEntity>> getSetlistOnce({
    required String groupId,
    required String rehearsalId,
  }) async {
    requireUid();
    logFirestore('getSetlistOnce groupId=$groupId rehearsalId=$rehearsalId');
    final snapshot = await logFuture(
      'getSetlistOnce get',
      setlist(groupId, rehearsalId).orderBy('order', descending: false).get(),
    );
    return snapshot.docs.map(_mapSetlistItem).toList();
  }

  Future<void> setSetlistOrders({
    required String groupId,
    required String rehearsalId,
    required List<String> itemIdsInOrder,
  }) async {
    requireUid();
    logFirestore(
      'setSetlistOrders groupId=$groupId rehearsalId=$rehearsalId count=${itemIdsInOrder.length}',
    );
    final batch = firestore.batch();
    for (var i = 0; i < itemIdsInOrder.length; i++) {
      batch.set(
        setlist(groupId, rehearsalId).doc(itemIdsInOrder[i]),
        {'order': i},
        SetOptions(merge: true),
      );
    }
    await logFuture('setSetlistOrders commit', batch.commit());
  }

  Future<void> clearSetlist({
    required String groupId,
    required String rehearsalId,
  }) async {
    requireUid();
    logFirestore('clearSetlist groupId=$groupId rehearsalId=$rehearsalId');
    final snapshot = await logFuture(
      'clearSetlist get',
      setlist(groupId, rehearsalId).get(),
    );
    if (snapshot.docs.isEmpty) return;
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await logFuture('clearSetlist commit', batch.commit());
  }

  Future<void> copySetlist({
    required String groupId,
    required String fromRehearsalId,
    required String toRehearsalId,
    bool replaceExisting = true,
  }) async {
    requireUid();
    logFirestore(
      'copySetlist groupId=$groupId from=$fromRehearsalId to=$toRehearsalId replaceExisting=$replaceExisting',
    );

    final source = await getSetlistOnce(
      groupId: groupId,
      rehearsalId: fromRehearsalId,
    );
    if (source.isEmpty) return;

    var orderOffset = 0;
    if (replaceExisting) {
      await clearSetlist(groupId: groupId, rehearsalId: toRehearsalId);
    } else {
      final existing = await getSetlistOnce(
        groupId: groupId,
        rehearsalId: toRehearsalId,
      );
      final maxOrder = existing.isEmpty
          ? -1
          : existing.map((e) => e.order).reduce((a, b) => a > b ? a : b);
      orderOffset = maxOrder + 1;
    }

    final batch = firestore.batch();
    for (final item in source) {
      final doc = setlist(groupId, toRehearsalId).doc();
      batch.set(doc, {
        'order': item.order + orderOffset,
        'songId': item.songId,
        'songTitle': item.songTitle,
        'key': item.keySignature,
        'tempoBpm': item.tempoBpm,
        'notes': item.notes,
        'linkUrl': item.linkUrl,
        // Intencional: no copiamos `sheetUrl/sheetPath` porque dependen del itemId en Storage.
      });
    }
    await logFuture('copySetlist commit', batch.commit());
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
    String linkUrl = '',
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
        'linkUrl': linkUrl.trim(),
      }),
    );
    return doc.id;
  }

  Future<String> uploadSetlistSheet({
    required String groupId,
    required String rehearsalId,
    required String itemId,
    required Uint8List bytes,
    String? fileExtension,
  }) async {
    requireUid();
    final ext = _normalizeImageExtension(fileExtension);
    final sheetPath =
        'groups/$groupId/rehearsals/$rehearsalId/setlist/$itemId/sheet.$ext';
    final ref = _storage.ref().child(sheetPath);
    final metadata = SettableMetadata(contentType: 'image/$ext');
    await logFuture('uploadSetlistSheet putData', ref.putData(bytes, metadata));
    final url = await logFuture(
      'uploadSetlistSheet getDownloadURL',
      ref.getDownloadURL(),
    );
    await logFuture(
      'uploadSetlistSheet merge sheetUrl',
      setlist(groupId, rehearsalId).doc(itemId).set({
        'sheetUrl': url,
        'sheetPath': sheetPath,
      }, SetOptions(merge: true)),
    );
    return url;
  }

  Future<void> updateSetlistItem({
    required String groupId,
    required String rehearsalId,
    required String itemId,
    required int order,
    required String songTitle,
    required String keySignature,
    required int? tempoBpm,
    required String notes,
    required String linkUrl,
  }) async {
    requireUid();
    logFirestore(
      'updateSetlistItem groupId=$groupId rehearsalId=$rehearsalId itemId=$itemId',
    );
    await logFuture(
      'updateSetlistItem set',
      setlist(groupId, rehearsalId).doc(itemId).set({
        'order': order,
        'songTitle': songTitle.trim(),
        'key': keySignature.trim(),
        'tempoBpm': tempoBpm,
        'notes': notes.trim(),
        'linkUrl': linkUrl.trim(),
      }, SetOptions(merge: true)),
    );
  }

  Future<void> clearSetlistSheet({
    required String groupId,
    required String rehearsalId,
    required String itemId,
    String sheetPath = '',
  }) async {
    requireUid();
    logFirestore(
      'clearSetlistSheet groupId=$groupId rehearsalId=$rehearsalId itemId=$itemId',
    );
    final path = sheetPath.trim();
    if (path.isNotEmpty) {
      try {
        await logFuture(
          'clearSetlistSheet delete',
          _storage.ref().child(path).delete(),
        );
      } catch (_) {
        // Ignore missing file or permission mismatch; we still clear the doc.
      }
    }
    await logFuture(
      'clearSetlistSheet merge clear fields',
      setlist(groupId, rehearsalId).doc(itemId).set({
        'sheetUrl': '',
        'sheetPath': '',
      }, SetOptions(merge: true)),
    );
  }

  Future<void> deleteSetlistItem({
    required String groupId,
    required String rehearsalId,
    required String itemId,
  }) async {
    requireUid();
    logFirestore(
      'deleteSetlistItem groupId=$groupId rehearsalId=$rehearsalId itemId=$itemId',
    );
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
      linkUrl: (data['linkUrl'] as String?)?.trim() ?? '',
      sheetUrl: (data['sheetUrl'] as String?)?.trim() ?? '',
      sheetPath: (data['sheetPath'] as String?)?.trim() ?? '',
    );
  }

  String _normalizeImageExtension(String? fileExtension) {
    final ext = (fileExtension ?? '').trim().toLowerCase();
    if (ext == 'jpeg') return 'jpg';
    if (ext == 'jpg') return 'jpg';
    if (ext == 'png') return 'png';
    if (ext == 'webp') return 'webp';
    return 'jpg';
  }
}
