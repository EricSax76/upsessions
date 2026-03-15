import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_entity.dart';
import '../models/room_entity.dart';
import '../models/studio_entity.dart';
import 'firestore_bookings_page_loader.dart';
import 'firestore_studios_mapper.dart';
import 'studios_repository.dart';

class FirestoreStudiosRepository implements StudiosRepository {
  FirestoreStudiosRepository({required FirebaseFirestore firestore})
    : _firestore = firestore,
      _bookingsPageLoader = FirestoreBookingsPageLoader(
        firestore: firestore,
        mapBooking: const FirestoreStudiosMapper().mapBooking,
      );

  static const int _bookingsPageSize = 200;

  final FirebaseFirestore _firestore;
  final FirestoreStudiosMapper _mapper = const FirestoreStudiosMapper();
  final FirestoreBookingsPageLoader _bookingsPageLoader;

  @override
  Future<void> createStudio(StudioEntity studio) async {
    await _firestore.collection('studios').doc(studio.id).set({
      'id': studio.id,
      'ownerId': studio.ownerId,
      'name': studio.name,
      'businessName': studio.businessName,
      'cif': studio.cif,
      'description': studio.description,
      'address': studio.address,
      'contactEmail': studio.contactEmail,
      'contactPhone': studio.contactPhone,
      if (studio.logoUrl != null) 'logoUrl': studio.logoUrl,
      if (studio.bannerUrl != null) 'bannerUrl': studio.bannerUrl,
      'vatNumber': studio.vatNumber,
      'licenseNumber': studio.licenseNumber,
      'openingHours': studio.openingHours,
      'city': studio.city,
      'province': studio.province,
      'postalCode': studio.postalCode,
      'maxRoomCapacity': studio.maxRoomCapacity,
      'accessibilityInfo': studio.accessibilityInfo,
      'noiseOrdinanceCompliant': studio.noiseOrdinanceCompliant,
      'insuranceExpiry': Timestamp.fromDate(studio.insuranceExpiry),
      'isActive': studio.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStudio(StudioEntity studio) async {
    await _firestore.collection('studios').doc(studio.id).update({
      'name': studio.name,
      'businessName': studio.businessName,
      'cif': studio.cif,
      'description': studio.description,
      'address': studio.address,
      'contactEmail': studio.contactEmail,
      'contactPhone': studio.contactPhone,
      if (studio.logoUrl != null) 'logoUrl': studio.logoUrl,
      if (studio.bannerUrl != null) 'bannerUrl': studio.bannerUrl,
      'vatNumber': studio.vatNumber,
      'licenseNumber': studio.licenseNumber,
      'openingHours': studio.openingHours,
      'city': studio.city,
      'province': studio.province,
      'postalCode': studio.postalCode,
      'maxRoomCapacity': studio.maxRoomCapacity,
      'accessibilityInfo': studio.accessibilityInfo,
      'noiseOrdinanceCompliant': studio.noiseOrdinanceCompliant,
      'insuranceExpiry': Timestamp.fromDate(studio.insuranceExpiry),
      'isActive': studio.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<StudioEntity?> getStudioByOwner(String userId) async {
    final querySnapshot = await _firestore
        .collection('studios')
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    final doc = querySnapshot.docs.first;
    return _mapper.tryMapStudio(doc.id, doc.data());
  }

  @override
  Future<StudioEntity?> getStudioById(String studioId) async {
    final docSnapshot = await _firestore
        .collection('studios')
        .doc(studioId)
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) return null;
    return _mapper.tryMapStudio(docSnapshot.id, docSnapshot.data()!);
  }

  @override
  Future<StudiosPage> getStudiosPage({String? cursor, int limit = 20}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('studios')
        .orderBy(FieldPath.documentId)
        .limit(limit + 1);
    final startAfterId = (cursor ?? '').trim();
    if (startAfterId.isNotEmpty) {
      query = query.startAfter([startAfterId]);
    }

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;
    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.take(limit).toList() : docs;

    final studios = <StudioEntity>[];
    for (final doc in pageDocs) {
      final studio = _mapper.tryMapStudio(doc.id, doc.data());
      if (studio != null) {
        studios.add(studio);
      }
    }

    final nextCursor = hasMore && pageDocs.isNotEmpty ? pageDocs.last.id : null;
    return StudiosPage(
      items: studios,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<List<StudioEntity>> getAllStudios() async {
    final studios = <StudioEntity>[];
    String? cursor;
    while (true) {
      final page = await getStudiosPage(cursor: cursor, limit: 100);
      studios.addAll(page.items);
      if (!page.hasMore || page.nextCursor == null) {
        break;
      }
      cursor = page.nextCursor;
    }
    return studios;
  }

  @override
  Future<void> createRoom(RoomEntity room) async {
    final now = FieldValue.serverTimestamp();
    await _firestore
        .collection('studios')
        .doc(room.studioId)
        .collection('rooms')
        .doc(room.id)
        .set({
          'id': room.id,
          'studioId': room.studioId,
          'name': room.name,
          'capacity': room.capacity,
          'size': room.size,
          'pricePerHour': room.pricePerHour,
          'equipment': room.equipment,
          'amenities': room.amenities,
          'photos': room.photos,
          'isActive': room.isActive,
          'isAccessible': room.isAccessible,
          'minBookingHours': room.minBookingHours,
          if (room.maxDecibels != null) 'maxDecibels': room.maxDecibels,
          if (room.cancellationPolicy != null)
            'cancellationPolicy': room.cancellationPolicy,
          if (room.ageRestriction != null)
            'ageRestriction': room.ageRestriction,
          'updatedAt': now,
        });
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    await _firestore
        .collection('studios')
        .doc(room.studioId)
        .collection('rooms')
        .doc(room.id)
        .update({
          'name': room.name,
          'capacity': room.capacity,
          'size': room.size,
          'pricePerHour': room.pricePerHour,
          'equipment': room.equipment,
          'amenities': room.amenities,
          'photos': room.photos,
          'isActive': room.isActive,
          'isAccessible': room.isAccessible,
          'minBookingHours': room.minBookingHours,
          if (room.maxDecibels != null) 'maxDecibels': room.maxDecibels,
          if (room.cancellationPolicy != null)
            'cancellationPolicy': room.cancellationPolicy,
          if (room.ageRestriction != null)
            'ageRestriction': room.ageRestriction,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> deleteRoom({
    required String studioId,
    required String roomId,
  }) async {
    await _firestore
        .collection('studios')
        .doc(studioId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }

  @override
  Future<RoomEntity?> getRoomById({
    required String studioId,
    required String roomId,
  }) async {
    final doc = await _firestore
        .collection('studios')
        .doc(studioId)
        .collection('rooms')
        .doc(roomId)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return _mapper.mapRoom(
      docId: doc.id,
      studioId: studioId,
      data: doc.data()!,
    );
  }

  @override
  Future<List<RoomEntity>> getRoomsByStudio(String studioId) async {
    final querySnapshot = await _firestore
        .collection('studios')
        .doc(studioId)
        .collection('rooms')
        .get();

    return querySnapshot.docs
        .map(
          (doc) => _mapper.mapRoom(
            docId: doc.id,
            studioId: studioId,
            data: doc.data(),
          ),
        )
        .toList();
  }

  @override
  Future<void> createBooking(BookingEntity booking) async {
    final data = <String, dynamic>{
      'id': booking.id,
      'roomId': booking.roomId,
      'roomName': booking.roomName,
      'studioId': booking.studioId,
      'studioName': booking.studioName,
      'ownerId': booking.ownerId,
      'startTime': Timestamp.fromDate(booking.startTime),
      'endTime': Timestamp.fromDate(booking.endTime),
      'status': booking.status.name,
      'totalPrice': booking.totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (booking.invoiceId != null) 'invoiceId': booking.invoiceId,
      if (booking.vatAmount != null) 'vatAmount': booking.vatAmount,
      'paymentStatus': booking.paymentStatus.name,
      if (booking.paymentMethod != null)
        'paymentMethod': booking.paymentMethod!.name,
      if (booking.cancellationReason != null)
        'cancellationReason': booking.cancellationReason,
      if (booking.refundAmount != null) 'refundAmount': booking.refundAmount,
      if (booking.confirmedAt != null)
        'confirmedAt': Timestamp.fromDate(booking.confirmedAt!),
      if (booking.attendees.isNotEmpty) 'attendees': booking.attendees,
      if (booking.rehearsalId != null) 'rehearsalId': booking.rehearsalId,
      if (booking.groupId != null) 'groupId': booking.groupId,
    };
    await _firestore.collection('bookings').doc(booking.id).set(data);
  }

  @override
  Future<void> updateBookingPayment({
    required String bookingId,
    required BookingPaymentStatus paymentStatus,
    BookingPaymentMethod? paymentMethod,
    String? invoiceId,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'paymentStatus': paymentStatus.name,
      if (paymentMethod != null) 'paymentMethod': paymentMethod.name,
      'invoiceId': ?invoiceId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
    double? refundAmount,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'cancellationReason': reason,
      'refundAmount': ?refundAmount,
      if (refundAmount != null && refundAmount > 0)
        'paymentStatus': BookingPaymentStatus.refunded.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<BookingEntity?> getBookingById(String bookingId) async {
    final docSnapshot = await _firestore
        .collection('bookings')
        .doc(bookingId)
        .get();
    if (!docSnapshot.exists || docSnapshot.data() == null) return null;
    return _mapper.mapBooking(docSnapshot);
  }

  @override
  Future<List<BookingEntity>> getBookingsByRoom(String roomId) async {
    return _bookingsPageLoader.collectPages(
      (cursor) =>
          getBookingsByRoomPage(roomId: roomId, cursor: cursor, limit: 100),
    );
  }

  @override
  Future<List<BookingEntity>> getBookingsByUser(String userId) async {
    return _bookingsPageLoader.collectPages(
      (cursor) =>
          getBookingsByUserPage(userId: userId, cursor: cursor, limit: 100),
    );
  }

  @override
  Future<List<BookingEntity>> getBookingsByStudio(String studioId) async {
    return _bookingsPageLoader.collectPages(
      (cursor) => getBookingsByStudioPage(
        studioId: studioId,
        cursor: cursor,
        limit: _bookingsPageSize,
      ),
    );
  }

  @override
  Future<BookingsPage> getBookingsByRoomPage({
    required String roomId,
    String? cursor,
    int limit = 20,
  }) {
    return _bookingsPageLoader.getPageByIndexedField(
      field: 'roomId',
      value: roomId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<BookingsPage> getBookingsByUserPage({
    required String userId,
    String? cursor,
    int limit = 20,
  }) {
    return _bookingsPageLoader.getPageByIndexedField(
      field: 'ownerId',
      value: userId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<BookingsPage> getBookingsByStudioPage({
    required String studioId,
    String? cursor,
    int limit = 20,
  }) {
    return _bookingsPageLoader.getPageByIndexedField(
      field: 'studioId',
      value: studioId,
      cursor: cursor,
      limit: limit,
    );
  }
}
