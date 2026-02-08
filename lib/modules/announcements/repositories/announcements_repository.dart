import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement_entity.dart';
import '../models/announcement_dto.dart';

enum AnnouncementFeedFilter { all, nearby, urgent }

class AnnouncementPage {
  const AnnouncementPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AnnouncementEntity> items;
  final bool hasMore;
  final String? nextCursor;
}

class AnnouncementsRepository {
  AnnouncementsRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        'announcements',
      );

  final CollectionReference<Map<String, dynamic>> _collection;

  Future<List<AnnouncementEntity>> fetchAll() async {
    final announcements = <AnnouncementEntity>[];
    String? cursor;
    while (true) {
      final page = await fetchPage(limit: 100, cursor: cursor);
      announcements.addAll(page.items);
      if (!page.hasMore || page.nextCursor == null) {
        break;
      }
      cursor = page.nextCursor;
    }
    return announcements;
  }

  Future<AnnouncementPage> fetchPage({
    AnnouncementFeedFilter filter = AnnouncementFeedFilter.all,
    String? city,
    String? province,
    String? cursor,
    int limit = 24,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .orderBy('publishedAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(limit + 1);

    if (filter == AnnouncementFeedFilter.urgent) {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 3)),
      );
      query = query.where('publishedAt', isGreaterThanOrEqualTo: cutoff);
    } else if (filter == AnnouncementFeedFilter.nearby) {
      final normalizedCity = city?.trim() ?? '';
      final normalizedProvince = province?.trim() ?? '';
      if (normalizedCity.isNotEmpty) {
        query = query.where('city', isEqualTo: normalizedCity);
      } else if (normalizedProvince.isNotEmpty) {
        query = query.where('province', isEqualTo: normalizedProvince);
      }
    }

    final parsedCursor = _decodeCursor(cursor);
    if (parsedCursor != null) {
      query = query.startAfter([
        Timestamp.fromMillisecondsSinceEpoch(parsedCursor.key),
        parsedCursor.value,
      ]);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await query.get();
    } on FirebaseException {
      if (filter != AnnouncementFeedFilter.nearby) {
        rethrow;
      }
      // Nearby can require additional composite indexes depending on data model.
      // If not available yet, fallback to unfiltered feed instead of failing.
      return fetchPage(
        filter: AnnouncementFeedFilter.all,
        cursor: cursor,
        limit: limit,
      );
    }

    final docs = snapshot.docs;
    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.take(limit).toList() : docs;
    final items = pageDocs
        .map((doc) => AnnouncementDto.fromDocument(doc).toEntity())
        .toList();
    final nextCursor = hasMore && pageDocs.isNotEmpty
        ? _encodeCursor(pageDocs.last)
        : null;
    return AnnouncementPage(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  Future<AnnouncementEntity> findById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Anuncio no encontrado');
    }
    return AnnouncementDto.fromDocument(doc).toEntity();
  }

  Future<AnnouncementEntity> create(AnnouncementEntity entity) async {
    final dto = AnnouncementDto.fromEntity(
      entity.copyWith(publishedAt: DateTime.now()),
    );

    final payload = {
      ...dto.toJson(),
      'publishedAt': FieldValue.serverTimestamp(),
    };

    if (entity.id.isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return AnnouncementDto.fromDocument(snapshot).toEntity();
    } else {
      await _collection.doc(entity.id).set(payload);
      final snapshot = await _collection.doc(entity.id).get();
      return AnnouncementDto.fromDocument(snapshot).toEntity();
    }
  }

  String _encodeCursor(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final publishedAt = (doc.data()['publishedAt'] as Timestamp?)?.toDate();
    final millis = (publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .millisecondsSinceEpoch;
    return '$millis|${doc.id}';
  }

  MapEntry<int, String>? _decodeCursor(String? cursor) {
    final raw = (cursor ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final separator = raw.lastIndexOf('|');
    if (separator <= 0 || separator >= raw.length - 1) {
      return null;
    }
    final millis = int.tryParse(raw.substring(0, separator));
    final docId = raw.substring(separator + 1);
    if (millis == null || docId.isEmpty) {
      return null;
    }
    return MapEntry<int, String>(millis, docId);
  }
}
