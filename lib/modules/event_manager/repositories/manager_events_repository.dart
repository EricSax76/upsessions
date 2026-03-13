import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../modules/events/models/event_dto.dart';
import '../../../../modules/events/models/event_entity.dart';
import '../../auth/repositories/auth_repository.dart';

class ManagerEventsRepository {
  ManagerEventsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _collection = firestore.collection('events'),
       _authRepository = authRepository;

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Future<List<EventEntity>> fetchMyEvents(
    String managerId, {
    int limit = 20,
  }) async {
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .orderBy('start', descending: true)
        .limit(limit)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<EventEntity>> fetchAllMyEvents(String managerId) async {
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .orderBy('start', descending: true)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<EventEntity>> fetchUpcoming(String managerId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .where('start', isGreaterThanOrEqualTo: now)
        .orderBy('start')
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<List<EventEntity>> fetchPast(String managerId) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _collection
        .where('ownerId', isEqualTo: managerId)
        .where('start', isLessThan: now)
        .orderBy('start', descending: true)
        .get();
    return _toEntities(snapshot.docs);
  }

  Future<EventEntity?> findById(String eventId) async {
    final managerId = _authRepository.currentUser?.id ?? '';
    if (managerId.isEmpty) return null;

    final doc = await _collection.doc(eventId).get();
    if (!doc.exists) return null;

    final event = EventDto.fromDocument(doc).toEntity();
    if (event.ownerId != managerId) return null;
    return event;
  }

  Future<EventEntity> saveDraft(EventEntity event) async {
    final ownerId = event.ownerId.isNotEmpty
        ? event.ownerId
        : (_authRepository.currentUser?.id ?? '');
    if (ownerId.isEmpty) {
      throw Exception('Necesitas iniciar sesión para crear un evento.');
    }

    final dto = EventDto.fromEntity(event.copyWith(ownerId: ownerId));
    final now = FieldValue.serverTimestamp();
    final payload = {
      ...dto.toJson(),
      'updatedAt': now,
      if (event.id.isEmpty) 'createdAt': now,
    };

    if (event.id.isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return EventDto.fromDocument(snapshot).toEntity();
    }

    await _collection.doc(event.id).set(payload, SetOptions(merge: true));
    final snapshot = await _collection.doc(event.id).get();
    return EventDto.fromDocument(snapshot).toEntity();
  }

  Future<void> delete(String eventId) async {
    await _collection.doc(eventId).delete();
  }

  List<EventEntity> _toEntities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map(EventDto.fromDocument)
        .map((dto) => dto.toEntity())
        .toList();
  }
}
