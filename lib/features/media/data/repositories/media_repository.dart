import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/media_item.dart';

class MediaRepository {
  MediaRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<List<MediaItem>> fetchMedia() async {
    final snapshot = await _firestore
        .collection('media_items')
        .orderBy('createdAt', descending: true)
        .get();
    final futures = snapshot.docs.map(_mapMediaItem).toList();
    return Future.wait(futures);
  }

  Future<MediaItem> _mapMediaItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final type = _parseType(data['type']);
    final durationSeconds = (data['durationSeconds'] as num?)?.toInt() ?? 0;
    final storagePath = (data['storagePath'] ?? '') as String;
    final thumbnailPath = data['thumbnailPath'] as String?;
    final url = storagePath.isEmpty
        ? ''
        : await _storage.ref(storagePath).getDownloadURL();
    final thumbnailUrl = thumbnailPath == null
        ? null
        : await _storage.ref(thumbnailPath).getDownloadURL();
    return MediaItem(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      type: type,
      duration: Duration(seconds: durationSeconds),
      url: url,
      thumbnailUrl: thumbnailUrl,
    );
  }

  MediaType _parseType(dynamic raw) {
    switch ((raw ?? '').toString().toLowerCase()) {
      case 'video':
        return MediaType.video;
      case 'image':
        return MediaType.image;
      default:
        return MediaType.audio;
    }
  }
}
