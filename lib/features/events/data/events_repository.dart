import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';

import '../domain/event_entity.dart';
import 'event_dto.dart';

class EventsRepository {
  EventsRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  }) : _collection = (firestore ?? FirebaseFirestore.instance).collection(
         'events',
       ),
       _authRepository = authRepository ?? AuthRepository();

  final CollectionReference<Map<String, dynamic>> _collection;
  final AuthRepository _authRepository;

  Future<List<EventEntity>> fetchUpcoming({int limit = 20}) async {
    final now = Timestamp.fromDate(DateTime.now());
    final upcomingSnapshot = await _collection
        .where('start', isGreaterThanOrEqualTo: now)
        .orderBy('start')
        .limit(limit)
        .get();
    if (upcomingSnapshot.docs.isNotEmpty) {
      return _toEntities(upcomingSnapshot.docs);
    }

    final fallbackSnapshot = await _collection
        .orderBy('start')
        .limit(limit)
        .get();
    return _toEntities(fallbackSnapshot.docs);
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

  List<EventEntity> _toEntities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map(EventDto.fromDocument)
        .map((dto) => dto.toEntity())
        .toList();
  }
}
