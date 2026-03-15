import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_entity.dart';
import 'studios_repository.dart';

typedef BookingMapper =
    BookingEntity Function(DocumentSnapshot<Map<String, dynamic>> doc);

class FirestoreBookingsPageLoader {
  const FirestoreBookingsPageLoader({
    required FirebaseFirestore firestore,
    required BookingMapper mapBooking,
    this.defaultLimit = 20,
    this.maxLimit = 200,
  }) : _firestore = firestore,
       _mapBooking = mapBooking;

  final FirebaseFirestore _firestore;
  final BookingMapper _mapBooking;
  final int defaultLimit;
  final int maxLimit;

  Future<List<BookingEntity>> collectPages(
    Future<BookingsPage> Function(String? cursor) loadPage,
  ) async {
    final bookings = <BookingEntity>[];
    String? cursor;
    while (true) {
      final page = await loadPage(cursor);
      bookings.addAll(page.items);
      if (!page.hasMore || page.nextCursor == null) {
        break;
      }
      cursor = page.nextCursor;
    }
    return bookings;
  }

  Future<BookingsPage> getPageByIndexedField({
    required String field,
    required String value,
    String? cursor,
    int limit = 20,
  }) async {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) {
      return const BookingsPage(items: <BookingEntity>[], hasMore: false);
    }

    final pageLimit = _normalizePageLimit(limit);
    Query<Map<String, dynamic>> query = _firestore
        .collection('bookings')
        .where(field, isEqualTo: normalizedValue)
        .orderBy('startTime', descending: true)
        .limit(pageLimit + 1);

    final cursorId = (cursor ?? '').trim();
    if (cursorId.isNotEmpty) {
      final cursorDoc = await _firestore
          .collection('bookings')
          .doc(cursorId)
          .get();
      final cursorData = cursorDoc.data();
      if (cursorDoc.exists &&
          cursorData != null &&
          cursorData['startTime'] != null) {
        query = query.startAfterDocument(cursorDoc);
      }
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    final hasMore = docs.length > pageLimit;
    final pageDocs = hasMore ? docs.take(pageLimit).toList() : docs;
    final nextCursor = hasMore && pageDocs.isNotEmpty ? pageDocs.last.id : null;

    return BookingsPage(
      items: pageDocs.map(_mapBooking).toList(),
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  int _normalizePageLimit(int value) {
    if (value <= 0) return defaultLimit;
    return value > maxLimit ? maxLimit : value;
  }
}
