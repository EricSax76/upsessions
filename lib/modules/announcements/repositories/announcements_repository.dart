import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement_entity.dart';
import '../models/announcement_dto.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        'announcements',
      );

  final CollectionReference<Map<String, dynamic>> _collection;

  Future<List<AnnouncementEntity>> fetchAll() async {
    final snapshot = await _collection
        .orderBy('publishedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AnnouncementDto.fromDocument(doc).toEntity())
        .toList();
  }

  Future<AnnouncementEntity> findById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Anuncio no encontrado');
    }
    return AnnouncementDto.fromDocument(doc).toEntity();
  }

  Future<AnnouncementEntity> create(AnnouncementEntity entity) async {
    final dto = AnnouncementDto.fromEntity(
      entity.copyWith(publishedAt: DateTime.now()),
    );

    final payload = {
      ...dto.toJson(),
      'publishedAt': FieldValue.serverTimestamp(),
    };

    if (entity.id.isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return AnnouncementDto.fromDocument(snapshot).toEntity();
    } else {
      await _collection.doc(entity.id).set(payload);
      final snapshot = await _collection.doc(entity.id).get();
      return AnnouncementDto.fromDocument(snapshot).toEntity();
    }
  }
}
