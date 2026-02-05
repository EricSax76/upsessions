import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';
import 'studios_repository.dart';

class FirestoreStudiosRepository implements StudiosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final docSnapshot = await _firestore.collection('studios').doc(studioId).get();
    
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
  Future<List<StudioEntity>> getAllStudios() async {
    final querySnapshot = await _firestore.collection('studios').get();

    return querySnapshot.docs.map((doc) {
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
    // Note: To properly delete, we usually need the studioId to construct the path.
    // However, the interface only gives roomId. 
    // Ideally we pass studioId or fetch the room first. 
    // Given the current architecture, assuming we can't easily change the interface right now without breaking existing code,
    // we might need to rely on a CollectionGroup query or adjust the interface.
    // BUT since this is MVP, let's assume the caller will likely have to handle this or we find the parent.
    // For now, I'll use a CollectionGroup query to find the parent studio if needed, OR 
    // update the interface to 'deleteRoom(String studioId, String roomId)' would be better.
    // I will assume for now that I need to find the room first to delete it or just skip this edge case if not critical. 
    // Actually, looking at the UI, we probably have the studio context.
    // For this exact implementation, I will implement a safety check:
    // "Warning: deleteRoom(roomId) is inefficient without studioId in Firestore structure."
    // Let's defer this complexity or just iterate studios (bad).
    // Better approach: Since `edit_room_page` (caller) knows the studioId, 
    // I will assume for this step I should update the interface or just search.
    // Let's do a search for now to be safe without changing interface yet.
    
    final query = await _firestore.collectionGroup('rooms').where('id', isEqualTo: roomId).get();
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
      if (photos.isEmpty && legacyPhotoUrl is String && legacyPhotoUrl.isNotEmpty) {
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
