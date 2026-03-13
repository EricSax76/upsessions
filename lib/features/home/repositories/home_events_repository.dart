import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/features/home/models/home_event_model.dart';

import 'home_repository_mappers.dart';

class HomeEventsRepository {
  HomeEventsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<HomeEventModel>> fetchUpcomingEvents({int limit = 6}) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _firestore
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .where('start', isGreaterThanOrEqualTo: now)
        .orderBy('start')
        .limit(limit)
        .get();
    return snapshot.docs.map(HomeRepositoryMappers.eventFromDoc).toList();
  }
}
