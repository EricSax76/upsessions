import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/modules/announcements/models/announcement_entity.dart';

import 'home_repository_mappers.dart';

class HomeAnnouncementsRepository {
  HomeAnnouncementsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<AnnouncementEntity>> fetchRecentAnnouncements() async {
    final snapshot = await _firestore
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('publishedAt', descending: true)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AnnouncementEntity(
        id: doc.id,
        title: (data['title'] ?? '') as String,
        body: (data['body'] ?? data['description'] ?? '') as String,
        city: (data['city'] ?? '') as String,
        author: (data['author'] ?? 'Unknown') as String,
        authorId: (data['authorId'] ?? '') as String,
        province: (data['province'] ?? '') as String,
        instrument: (data['instrument'] ?? '') as String,
        styles: HomeRepositoryMappers.stringList(data['styles']),
        publishedAt: HomeRepositoryMappers.parseTimestamp(data['publishedAt']),
        imageUrl: data['imageUrl'] as String?,
      );
    }).toList();
  }
}
