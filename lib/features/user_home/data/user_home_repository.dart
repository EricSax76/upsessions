import 'package:cloud_firestore/cloud_firestore.dart';

import 'announcement_model.dart';
import 'instrument_category_model.dart';
import 'musician_card_model.dart';

class UserHomeRepository {
  UserHomeRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<MusicianCardModel>> fetchRecommendedMusicians() async {
    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('rating', descending: true)
        .limit(6)
        .get();
    return snapshot.docs.map(_mapMusician).toList();
  }

  Future<List<MusicianCardModel>> fetchNewMusicians() async {
    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('createdAt', descending: true)
        .limit(6)
        .get();
    return snapshot.docs.map(_mapMusician).toList();
  }

  Future<List<AnnouncementModel>> fetchRecentAnnouncements() async {
    final snapshot = await _firestore
        .collection('announcements')
        .orderBy('publishedAt', descending: true)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AnnouncementModel(
        id: doc.id,
        title: (data['title'] ?? '') as String,
        description: (data['body'] ?? data['description'] ?? '') as String,
        city: (data['city'] ?? '') as String,
        date: _parseTimestamp(data['publishedAt']),
      );
    }).toList();
  }

  Future<List<InstrumentCategoryModel>> fetchInstrumentCategories() async {
    final snapshot = await _firestore.collection('instrument_categories').orderBy('category').get();
    return snapshot.docs
        .map((doc) => InstrumentCategoryModel(
              category: (doc.data()['category'] ?? '') as String,
              instruments: _stringList(doc.data()['instruments']),
            ))
        .toList();
  }

  Future<List<String>> fetchProvinces() async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    if (!doc.exists) {
      return const [];
    }
    return _stringList(doc.data()?['provinces']);
  }

  Future<List<String>> fetchCitiesForProvince(String province) async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    if (!doc.exists) {
      return const [];
    }
    final data = doc.data();
    final byProvince = data?['citiesByProvince'];
    if (byProvince is Map<String, dynamic>) {
      final cities = byProvince[province];
      return _stringList(cities);
    }
    return const [];
  }

  static MusicianCardModel _mapMusician(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final styles = _stringList(data['styles']);
    return MusicianCardModel(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      instrument: (data['instrument'] ?? '') as String,
      location: (data['city'] ?? '') as String,
      style: styles.isNotEmpty ? styles.first : '',
      avatarUrl: data['photoUrl'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
