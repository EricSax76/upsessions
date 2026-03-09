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
      if (studio.logoUrl != null) 'logoUrl': studio.logoUrl,
      if (studio.bannerUrl != null) 'bannerUrl': studio.bannerUrl,
      // Normativa
      if (studio.vatNumber != null) 'vatNumber': studio.vatNumber,
      if (studio.licenseNumber != null) 'licenseNumber': studio.licenseNumber,
      if (studio.openingHours.isNotEmpty) 'openingHours': studio.openingHours,
      'city': studio.city,
      'province': studio.province,
      if (studio.postalCode != null) 'postalCode': studio.postalCode,
      if (studio.maxRoomCapacity != null)
        'maxRoomCapacity': studio.maxRoomCapacity,
      if (studio.accessibilityInfo != null)
        'accessibilityInfo': studio.accessibilityInfo,
      if (studio.noiseOrdinanceCompliant != null)
        'noiseOrdinanceCompliant': studio.noiseOrdinanceCompliant,
      if (studio.insuranceExpiry != null)
        'insuranceExpiry': Timestamp.fromDate(studio.insuranceExpiry!),
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
      // Normativa
      if (studio.vatNumber != null) 'vatNumber': studio.vatNumber,
      if (studio.licenseNumber != null) 'licenseNumber': studio.licenseNumber,
      if (studio.openingHours.isNotEmpty) 'openingHours': studio.openingHours,
      'city': studio.city,
      'province': studio.province,
      if (studio.postalCode != null) 'postalCode': studio.postalCode,
      if (studio.maxRoomCapacity != null)
        'maxRoomCapacity': studio.maxRoomCapacity,
      if (studio.accessibilityInfo != null)
        'accessibilityInfo': studio.accessibilityInfo,
      if (studio.noiseOrdinanceCompliant != null)
        'noiseOrdinanceCompliant': studio.noiseOrdinanceCompliant,
      if (studio.insuranceExpiry != null)
        'insuranceExpiry': Timestamp.fromDate(studio.insuranceExpiry!),
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
    return _mapStudio(
      querySnapshot.docs.first.id,
      querySnapshot.docs.first.data(),
    );
  }

  @override
  Future<StudioEntity?> getStudioById(String studioId) async {
    final docSnapshot = await _firestore
        .collection('studios')
        .doc(studioId)
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) return null;
    return _mapStudio(docSnapshot.id, docSnapshot.data()!);
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

    final studios = pageDocs
        .map((doc) => _mapStudio(doc.id, doc.data()))
        .toList();

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
          // Normativa
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
          // Normativa
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

    if (!doc.exists) return null;

    final data = doc.data()!;
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
      isActive: (data['isActive'] as bool?) ?? true,
      isAccessible: (data['isAccessible'] as bool?) ?? false,
      minBookingHours: (data['minBookingHours'] as num?)?.toInt() ?? 1,
      maxDecibels: (data['maxDecibels'] as num?)?.toDouble(),
      cancellationPolicy: data['cancellationPolicy'] as String?,
      ageRestriction: (data['ageRestriction'] as num?)?.toInt(),
      updatedAt: _tsToDate(data['updatedAt']),
    );
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
        // Normativa
        isActive: (data['isActive'] as bool?) ?? true,
        isAccessible: (data['isAccessible'] as bool?) ?? false,
        minBookingHours: (data['minBookingHours'] as num?)?.toInt() ?? 1,
        maxDecibels: (data['maxDecibels'] as num?)?.toDouble(),
        cancellationPolicy: data['cancellationPolicy'] as String?,
        ageRestriction: (data['ageRestriction'] as num?)?.toInt(),
        updatedAt: _tsToDate(data['updatedAt']),
      );
    }).toList();
  }

  @override
  Future<void> createBooking(BookingEntity booking) async {
    final now = Timestamp.fromDate(DateTime.now());
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
      // RGPD Art. 30 / contabilidad
      'createdAt': now,
      'updatedAt': now,
      // LIVA Art. 75 / AEAT — facturación legal
      if (booking.invoiceId != null) 'invoiceId': booking.invoiceId,
      if (booking.vatAmount != null) 'vatAmount': booking.vatAmount,
      // PSD2 — trazabilidad de pagos
      'paymentStatus': booking.paymentStatus.name,
      if (booking.paymentMethod != null)
        'paymentMethod': booking.paymentMethod!.name,
      // Directiva 2011/83/UE
      if (booking.cancellationReason != null)
        'cancellationReason': booking.cancellationReason,
      if (booking.refundAmount != null) 'refundAmount': booking.refundAmount,
      // Contractual
      if (booking.confirmedAt != null)
        'confirmedAt': Timestamp.fromDate(booking.confirmedAt!),
      // Responsabilidad civil / aforo
      if (booking.attendees.isNotEmpty) 'attendees': booking.attendees,
      // Opcionales existentes
      if (booking.rehearsalId != null) 'rehearsalId': booking.rehearsalId,
      if (booking.groupId != null) 'groupId': booking.groupId,
    };
    await _firestore.collection('bookings').doc(booking.id).set(data);
  }

  /// Actualiza el estado de pago de una reserva (PSD2 / contabilidad).
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

  /// Cancela una reserva con motivo (Directiva 2011/83/UE).
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
      // Normativa
      createdAt: _tsToDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _tsToDate(data['updatedAt']),
      invoiceId: data['invoiceId'] as String?,
      vatAmount: (data['vatAmount'] as num?)?.toDouble(),
      paymentMethod: _parseEnum(
        BookingPaymentMethod.values,
        data['paymentMethod'] as String?,
      ),
      paymentStatus:
          _parseEnum(
            BookingPaymentStatus.values,
            data['paymentStatus'] as String?,
          ) ??
          BookingPaymentStatus.pending,
      cancellationReason: data['cancellationReason'] as String?,
      refundAmount: (data['refundAmount'] as num?)?.toDouble(),
      confirmedAt: _tsToDate(data['confirmedAt']),
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  StudioEntity _mapStudio(String docId, Map<String, dynamic> data) {
    return StudioEntity(
      id: data['id'] ?? docId,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      businessName: data['businessName'] ?? '',
      cif: data['cif'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      logoUrl: data['logoUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      // Normativa
      vatNumber: data['vatNumber'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      openingHours:
          (data['openingHours'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
      city: data['city'] as String? ?? '',
      province: data['province'] as String? ?? '',
      postalCode: data['postalCode'] as String?,
      maxRoomCapacity: (data['maxRoomCapacity'] as num?)?.toInt(),
      accessibilityInfo: data['accessibilityInfo'] as String?,
      noiseOrdinanceCompliant: data['noiseOrdinanceCompliant'] as bool?,
      insuranceExpiry: _tsToDate(data['insuranceExpiry']),
      updatedAt: _tsToDate(data['updatedAt']),
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  static DateTime? _tsToDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    return null;
  }

  static T? _parseEnum<T extends Enum>(List<T> values, String? raw) {
    if (raw == null) return null;
    return values.cast<T?>().firstWhere(
      (e) => e?.name == raw,
      orElse: () => null,
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
