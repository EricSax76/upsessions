import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/spanish_geography.dart';
import '../../modules/auth/data/auth_repository.dart';
import '../../modules/musicians/models/musician_dto.dart';
import '../../modules/musicians/models/musician_entity.dart';
import '../../modules/rehearsals/cubits/rehearsal_entity.dart';
import '../models/announcement_model.dart';
import '../models/home_event_model.dart';
import '../models/instrument_category_model.dart';

class UserHomeRepository {
  UserHomeRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  Future<List<MusicianEntity>> fetchRecommendedMusicians() async {
    final snapshot = await _firestore
        .collection('musicians')
        .orderBy('rating', descending: true)
        .limit(6)
        .get();
    return snapshot.docs.map(_mapMusician).toList();
  }

  Future<List<MusicianEntity>> fetchNewMusicians() async {
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
    final snapshot = await _firestore
        .collection('instrument_categories')
        .orderBy('category')
        .get();
    return snapshot.docs
        .map(
          (doc) => InstrumentCategoryModel(
            category: (doc.data()['category'] ?? '') as String,
            instruments: _stringList(doc.data()['instruments']),
          ),
        )
        .toList();
  }

  Future<List<String>> fetchProvinces() async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    if (!doc.exists) {
      return spanishProvinces;
    }
    final provinces = _stringList(doc.data()?['provinces']);
    return provinces.isNotEmpty ? provinces : spanishProvinces;
  }

  Future<List<String>> fetchCitiesForProvince(String province) async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    final fallback = spanishCitiesByProvince[province] ?? const [];
    if (!doc.exists) {
      return fallback;
    }
    final data = doc.data();
    final byProvince = data?['citiesByProvince'];
    if (byProvince is Map<String, dynamic>) {
      final cities = byProvince[province];
      final resolved = _stringList(cities);
      return resolved.isNotEmpty ? resolved : fallback;
    }
    return fallback;
  }

  Future<List<HomeEventModel>> fetchUpcomingEvents({int limit = 6}) async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await _firestore
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: now)
        .orderBy('start')
        .limit(limit)
        .get();
    if (snapshot.docs.isEmpty) {
      final fallback = await _firestore
          .collection('events')
          .orderBy('start', descending: true)
          .limit(limit)
          .get();
      return fallback.docs.map(_mapEvent).toList();
    }
    return snapshot.docs.map(_mapEvent).toList();
  }

  Future<List<RehearsalEntity>> fetchUpcomingRehearsals({int limit = 5}) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return [];
    }
    final memberships = await _firestore
        .collectionGroup('members')
        .where('ownerId', isEqualTo: user.id)
        .where('status', isEqualTo: 'active')
        .get();
    final groupIds =
        memberships.docs
            .map((doc) => doc.reference.parent.parent?.id ?? '')
            .where((groupId) => groupId.isNotEmpty)
            .toSet()
            .toList();
    if (groupIds.isEmpty) {
      return [];
    }
    final now = Timestamp.fromDate(DateTime.now());
    
    // Fetch a few upcoming from each group to ensure we get the overall top ones
    // We fetch 'limit' from each group to be safe, though this might be over-fetching slightly,
    // it ensures correctness if all next rehearsals are in one group.
    final futures = groupIds.map((groupId) async {
      try {
        final snapshot = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('rehearsals')
            .where('startsAt', isGreaterThanOrEqualTo: now)
            .orderBy('startsAt')
            .limit(limit)
            .get();
        if (snapshot.docs.isEmpty) {
          return <RehearsalEntity>[];
        }
        return snapshot.docs
            .map((doc) => _mapRehearsal(doc, groupId: groupId))
            .toList();
      } catch (_) {
        return <RehearsalEntity>[];
      }
    });

    final results = await Future.wait(futures);
    final allRehearsals = results.expand((x) => x).toList();
    
    if (allRehearsals.isEmpty) {
      return [];
    }
    
    allRehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    
    return allRehearsals.take(limit).toList();
  }

  static MusicianEntity _mapMusician(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return MusicianDto.fromDocument(doc).toEntity();
  }

  static HomeEventModel _mapEvent(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return HomeEventModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      venue: (data['venue'] ?? '') as String,
      start: _parseTimestamp(data['start']),
      description: (data['description'] ?? '') as String,
      organizer: (data['organizer'] ?? '') as String,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      ticketInfo: (data['ticketInfo'] ?? '') as String,
      tags: _stringList(data['tags']),
      bannerImageUrl: data['bannerImageUrl'] as String?,
    );
  }

  static RehearsalEntity _mapRehearsal(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String groupId,
  }) {
    final data = doc.data();
    final startsAt =
        (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endsAt = (data['endsAt'] as Timestamp?)?.toDate();
    return RehearsalEntity(
      id: doc.id,
      groupId: groupId,
      startsAt: startsAt,
      endsAt: endsAt,
      location: (data['location'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
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
