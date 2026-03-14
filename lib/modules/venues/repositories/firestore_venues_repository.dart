import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venue_dto.dart';
import '../models/venue_entity.dart';
import 'venues_repository.dart';

class FirestoreVenuesRepository implements VenuesRepository {
  FirestoreVenuesRepository({required FirebaseFirestore firestore})
    : _collection = firestore.collection('venues');

  final CollectionReference<Map<String, dynamic>> _collection;

  @override
  Future<void> createVenue(VenueEntity venue) async {
    final dto = VenueDto.fromEntity(venue);
    await _collection.doc(venue.id).set({
      ...dto.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateVenue(VenueEntity venue) async {
    final dto = VenueDto.fromEntity(venue);
    await _collection.doc(venue.id).set({
      ...dto.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<VenueEntity> saveDraft(VenueEntity venue) async {
    final dto = VenueDto.fromEntity(venue);
    final payload = {
      ...dto.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (venue.id.trim().isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    };

    if (venue.id.trim().isEmpty) {
      final ref = await _collection.add(payload);
      final snapshot = await ref.get();
      return VenueDto.fromDocument(snapshot).toEntity();
    }

    await _collection.doc(venue.id).set(payload, SetOptions(merge: true));
    final snapshot = await _collection.doc(venue.id).get();
    return VenueDto.fromDocument(snapshot).toEntity();
  }

  @override
  Future<void> deactivateVenue(String venueId) async {
    await _collection.doc(venueId).set({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<VenueEntity?> getVenueById(String venueId) async {
    final snapshot = await _collection.doc(venueId).get();
    if (!snapshot.exists) return null;
    return VenueDto.fromDocument(snapshot).toEntity();
  }

  @override
  Future<VenuesPage> getOwnerVenuesPage({
    required String ownerId,
    String? cursor,
    int limit = 20,
  }) async {
    var query = _collection
        .where('ownerId', isEqualTo: ownerId)
        .where('isActive', isEqualTo: true)
        .orderBy(FieldPath.documentId)
        .limit(limit + 1);
    final startAfterId = (cursor ?? '').trim();
    if (startAfterId.isNotEmpty) {
      query = query.startAfter([startAfterId]);
    }
    final docs = (await query.get()).docs;
    return _pageFromDocs(docs, limit);
  }

  @override
  Future<VenuesPage> getPublicVenuesPage({
    String? cursor,
    int limit = 20,
    String? city,
    String? province,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true);

    final normalizedCity = (city ?? '').trim();
    final normalizedProvince = (province ?? '').trim();
    if (normalizedCity.isNotEmpty) {
      query = query.where('city', isEqualTo: normalizedCity);
    }
    if (normalizedProvince.isNotEmpty) {
      query = query.where('province', isEqualTo: normalizedProvince);
    }

    query = query.orderBy(FieldPath.documentId).limit(limit + 1);

    final startAfterId = (cursor ?? '').trim();
    if (startAfterId.isNotEmpty) {
      query = query.startAfter([startAfterId]);
    }

    final docs = (await query.get()).docs;
    return _pageFromDocs(docs, limit);
  }

  @override
  Future<List<VenueEntity>> getSelectableVenues({
    required String ownerId,
    int limit = 100,
  }) async {
    final safeLimit = limit <= 0 ? 100 : limit;
    final resolvedLimit = safeLimit > 300 ? 300 : safeLimit;

    final results = await Future.wait([
      _collection
          .where('ownerId', isEqualTo: ownerId)
          .where('isActive', isEqualTo: true)
          .limit(resolvedLimit)
          .get(),
      _collection
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(resolvedLimit)
          .get(),
    ]);

    final merged = <String, VenueEntity>{};
    for (final snapshot in results) {
      for (final doc in snapshot.docs) {
        merged[doc.id] = VenueDto.fromDocument(doc).toEntity();
      }
    }

    final venues = merged.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (venues.length <= resolvedLimit) return venues;
    return venues.sublist(0, resolvedLimit);
  }

  VenuesPage _pageFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int limit,
  ) {
    final safeLimit = limit <= 0 ? 20 : limit;
    final hasMore = docs.length > safeLimit;
    final pageDocs = hasMore ? docs.take(safeLimit).toList() : docs;
    final items =
        pageDocs.map((doc) => VenueDto.fromDocument(doc).toEntity()).toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    final nextCursor = hasMore && pageDocs.isNotEmpty ? pageDocs.last.id : null;
    return VenuesPage(items: items, hasMore: hasMore, nextCursor: nextCursor);
  }
}
