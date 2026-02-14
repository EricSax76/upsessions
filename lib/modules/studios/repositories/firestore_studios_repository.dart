import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';
import 'studios_repository.dart';

class FirestoreStudiosRepository implements StudiosRepository {
  FirestoreStudiosRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

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
      'logoUrl': studio.logoUrl,
      'bannerUrl': studio.bannerUrl,
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
      'logoUrl': studio.logoUrl,
      'bannerUrl': studio.bannerUrl,
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
    final data = doc.data();

    return StudioEntity(
      id: data['id'] ?? doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      businessName: data['businessName'] ?? '',
      cif: data['cif'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      logoUrl: data['logoUrl'],
      bannerUrl: data['bannerUrl'],
    );
  }

  @override
  Future<StudioEntity?> getStudioById(String studioId) async {
    final docSnapshot = await _firestore
        .collection('studios')
        .doc(studioId)
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) return null;

    final data = docSnapshot.data()!;

    return StudioEntity(
      id: data['id'] ?? docSnapshot.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      businessName: data['businessName'] ?? '',
      cif: data['cif'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      logoUrl: data['logoUrl'],
      bannerUrl: data['bannerUrl'],
    );
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

    final studios = pageDocs.map((doc) {
      final data = doc.data();
      return StudioEntity(
        id: data['id'] ?? doc.id,
        ownerId: data['ownerId'] ?? '',
        name: data['name'] ?? '',
        businessName: data['businessName'] ?? '',
        cif: data['cif'] ?? '',
        description: data['description'] ?? '',
        address: data['address'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhone: data['contactPhone'] ?? '',
        logoUrl: data['logoUrl'],
        bannerUrl: data['bannerUrl'],
      );
    }).toList();

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
        });
  }

  @override
  Future<void> deleteRoom(String roomId) async {


    final query = await _firestore
        .collectionGroup('rooms')
        .where('id', isEqualTo: roomId)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<RoomEntity>> getRoomsByStudio(String studioId) async {
    final querySnapshot = await _firestore
        .collection('studios')
        .doc(studioId)
        .collection('rooms')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final legacyPhotoUrl = data['photoUrl'];
      final photos = List<String>.from(data['photos'] ?? []);
      if (photos.isEmpty &&
          legacyPhotoUrl is String &&
          legacyPhotoUrl.isNotEmpty) {
        photos.add(legacyPhotoUrl);
      }
      return RoomEntity(
        id: data['id'] ?? doc.id,
        studioId: data['studioId'] ?? studioId,
        name: data['name'] ?? '',
        capacity: (data['capacity'] as num?)?.toInt() ?? 0,
        size: data['size'] ?? '',
        pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
        equipment: List<String>.from(data['equipment'] ?? []),
        amenities: List<String>.from(data['amenities'] ?? []),
        photos: photos,
      );
    }).toList();
  }

  @override
  Future<void> createBooking(BookingEntity booking) async {
    final data = {
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
    };
    if (booking.rehearsalId != null) {
      data['rehearsalId'] = booking.rehearsalId!;
    }
    if (booking.groupId != null) {
      data['groupId'] = booking.groupId!;
    }
    await _firestore.collection('bookings').doc(booking.id).set(data);
  }

  @override
  Future<BookingEntity?> getBookingById(String bookingId) async {
    final docSnapshot = await _firestore
        .collection('bookings')
        .doc(bookingId)
        .get();
    if (!docSnapshot.exists || docSnapshot.data() == null) return null;
    return _mapBooking(docSnapshot);
  }

  @override
  Future<List<BookingEntity>> getBookingsByRoom(String roomId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('roomId', isEqualTo: roomId)
        .orderBy('startTime', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => _mapBooking(doc)).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsByUser(String userId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => _mapBooking(doc)).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsByStudio(String studioId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('studioId', isEqualTo: studioId)
        .orderBy('startTime', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => _mapBooking(doc)).toList();
  }

  BookingEntity _mapBooking(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    // Fallback for existing data if studioId missing (shouldn't happen with new logic but safe)
    final studioId = data['studioId'] as String? ?? '';

    return BookingEntity(
      id: data['id'] ?? doc.id,
      roomId: data['roomId'] ?? '',
      roomName: data['roomName'] ?? '',
      studioId: studioId,
      studioName: data['studioName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: _parseBookingStatus(data['status']),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      rehearsalId: data['rehearsalId'] as String?,
      groupId: data['groupId'] as String?,
    );
  }
}

BookingStatus _parseBookingStatus(dynamic raw) {
  if (raw is String) {
    return BookingStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => BookingStatus.pending,
    );
  }
  if (raw is int && raw >= 0 && raw < BookingStatus.values.length) {
    return BookingStatus.values[raw];
  }
  return BookingStatus.pending;
}
