import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';

import '../models/event_entity.dart';
import '../models/event_dto.dart';
import '../models/event_enums.dart';

class EventsRepository {
  EventsRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  }) : _collection = firestore.collection('events'),
       _authRepository = authRepository;

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

  /// Fetches a balanced feed for calendar views:
  /// recent past events plus upcoming events around "now".
  Future<List<EventEntity>> fetchCalendarFeed({
    int upcomingLimit = 60,
    int pastLimit = 60,
  }) async {
    final now = Timestamp.fromDate(DateTime.now());

    final upcomingFuture = _collection
        .where('start', isGreaterThanOrEqualTo: now)
        .orderBy('start')
        .limit(upcomingLimit)
        .get();

    final pastFuture = _collection
        .where('start', isLessThan: now)
        .orderBy('start', descending: true)
        .limit(pastLimit)
        .get();

    final snapshots = await Future.wait([upcomingFuture, pastFuture]);
    final upcoming = _toEntities(snapshots[0].docs);
    final pastDescending = _toEntities(snapshots[1].docs);
    final pastAscending = pastDescending.reversed.toList(growable: false);

    return [...pastAscending, ...upcoming];
  }

  Future<EventEntity?> findById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return EventDto.fromDocument(doc).toEntity();
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
    final isPublishing =
        event.status == EventStatus.published && event.publishedAt == null;
    final payload = {
      ...dto.toJson(),
      'updatedAt': now,
      if (event.id.isEmpty) 'createdAt': now,
      if (isPublishing) 'publishedAt': now,
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
