import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/announcement_entity.dart';
import 'announcement_dto.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({FirebaseFirestore? firestore})
      : _collection = (firestore ?? FirebaseFirestore.instance).collection('announcements');

  final CollectionReference<Map<String, dynamic>> _collection;

  Future<List<AnnouncementEntity>> fetchAll() async {
    final snapshot = await _collection.orderBy('publishedAt', descending: true).get();
    return snapshot.docs.map((doc) => AnnouncementDto.fromDocument(doc).toEntity()).toList();
  }

  Future<AnnouncementEntity> findById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Anuncio no encontrado');
    }
    return AnnouncementDto.fromDocument(doc).toEntity();
  }

  Future<void> create(AnnouncementEntity entity) async {
    final dto = AnnouncementDto.fromEntity(entity);
    if (entity.id.isEmpty) {
      await _collection.add(dto.toJson());
    } else {
      await _collection.doc(entity.id).set(dto.toJson());
    }
  }
}
