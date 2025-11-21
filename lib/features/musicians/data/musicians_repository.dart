import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/musician_entity.dart';
import 'musician_dto.dart';

class MusiciansRepository {
  MusiciansRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collectionName = 'musicians';

  Future<List<MusicianEntity>> search({String query = '', int limit = 50}) async {
    final normalizedQuery = query.trim().toLowerCase();
    final snapshot = await _firestore.collection(_collectionName).orderBy('name').limit(limit).get();
    final musicians = snapshot.docs.map(MusicianDto.fromDocument).map((dto) => dto.toEntity()).toList();
    if (normalizedQuery.isEmpty) {
      return musicians;
    }
    return musicians
        .where(
          (musician) => musician.name.toLowerCase().contains(normalizedQuery) ||
              musician.styles.any((style) => style.toLowerCase().contains(normalizedQuery)),
        )
        .toList();
  }

  Future<MusicianEntity?> findById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return MusicianDto.fromDocument(doc).toEntity();
  }
}
