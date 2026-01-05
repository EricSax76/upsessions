import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import '../cubits/setlist_item_entity.dart';
import 'rehearsals_repository_base.dart';

class SetlistRepository extends RehearsalsRepositoryBase {
  SetlistRepository({
    super.firestore,
    super.authRepository,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

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
