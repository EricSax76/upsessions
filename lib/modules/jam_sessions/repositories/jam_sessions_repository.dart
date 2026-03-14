import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jam_session_dto.dart';
import '../models/jam_session_entity.dart';
import '../../auth/repositories/auth_repository.dart';

class JamSessionsRepository {
  JamSessionsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _collection = firestore.collection('jam_sessions'),
       _authRepository = authRepository;

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Future<List<JamSessionEntity>> fetchMySessions(
    String managerId, {
    int limit = 20,
  }) async {
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<JamSessionEntity>> fetchUpcoming(String managerId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .where('isPublic', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: now)
        .orderBy('date')
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<JamSessionEntity>> fetchPublicUpcoming({int limit = 50}) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('isPublic', isEqualTo: true)
        .where('isCanceled', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: now)
        .orderBy('date')
        .limit(limit)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<JamSessionEntity?> findById(String sessionId) async {
    final doc = await _collection.doc(sessionId).get();
    if (!doc.exists) return null;
    return JamSessionDto.fromDocument(doc).toEntity();
  }

  Future<JamSessionEntity> saveDraft(JamSessionEntity session) async {
    final ownerId = session.ownerId.isNotEmpty
        ? session.ownerId
        : (_authRepository.currentUser?.id ?? '');
    if (ownerId.isEmpty) {
      throw Exception('Necesitas iniciar sesión para crear una jam session.');
    }

    final dto = JamSessionDto.fromEntity(session.copyWith(ownerId: ownerId));
    final now = FieldValue.serverTimestamp();
    final payload = {
      ...dto.toJson(),
      'updatedAt': now,
      if (session.id.isEmpty) 'createdAt': now,
    };

    if (session.id.isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return JamSessionDto.fromDocument(snapshot).toEntity();
    }

    await _collection.doc(session.id).set(payload, SetOptions(merge: true));
    final snapshot = await _collection.doc(session.id).get();
    return JamSessionDto.fromDocument(snapshot).toEntity();
  }

  Future<void> delete(String sessionId) async {
    await _collection.doc(sessionId).delete();
  }

  /// Añade un usuario a la lista de asistentes (Responsabilidad civil / aforo).
  Future<void> joinJam({
    required String sessionId,
    required String userId,
  }) async {
    await _collection.doc(sessionId).update({
      'attendees': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<JamSessionEntity> _toEntities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => JamSessionDto.fromDocument(doc))
        .map((dto) => dto.toEntity())
        .toList();
  }
}
