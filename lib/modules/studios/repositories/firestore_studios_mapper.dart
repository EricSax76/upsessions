import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/booking_entity.dart';
import '../models/room_entity.dart';
import '../models/studio_entity.dart';

class FirestoreStudiosMapper {
  const FirestoreStudiosMapper();

  StudioEntity? tryMapStudio(String docId, Map<String, dynamic> data) {
    try {
      return mapStudio(docId: docId, data: data);
    } on FormatException catch (error) {
      assert(() {
        debugPrint('Skipping invalid studio "$docId": ${error.message}');
        return true;
      }());
      return null;
    }
  }

  StudioEntity mapStudio({
    required String docId,
    required Map<String, dynamic> data,
  }) {
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
      vatNumber: _requiredNonEmptyString(data, field: 'vatNumber'),
      licenseNumber: _requiredNonEmptyString(data, field: 'licenseNumber'),
      openingHours: _requiredNonEmptyStringMap(data, field: 'openingHours'),
      city: _requiredNonEmptyString(data, field: 'city'),
      province: _requiredNonEmptyString(data, field: 'province'),
      postalCode: _requiredNonEmptyString(data, field: 'postalCode'),
      maxRoomCapacity: _requiredPositiveInt(data, field: 'maxRoomCapacity'),
      accessibilityInfo: _requiredNonEmptyString(
        data,
        field: 'accessibilityInfo',
      ),
      noiseOrdinanceCompliant: _requiredBool(
        data,
        field: 'noiseOrdinanceCompliant',
      ),
      insuranceExpiry: _requiredTimestamp(data, field: 'insuranceExpiry'),
      updatedAt: tsToDate(data['updatedAt']),
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  RoomEntity mapRoom({
    required String docId,
    required String studioId,
    required Map<String, dynamic> data,
  }) {
    final legacyPhotoUrl = data['photoUrl'];
    final photos = List<String>.from(data['photos'] ?? []);
    if (photos.isEmpty &&
        legacyPhotoUrl is String &&
        legacyPhotoUrl.isNotEmpty) {
      photos.add(legacyPhotoUrl);
    }

    return RoomEntity(
      id: data['id'] ?? docId,
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
      updatedAt: tsToDate(data['updatedAt']),
    );
  }

  BookingEntity mapBooking(DocumentSnapshot<Map<String, dynamic>> doc) {
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
      createdAt: tsToDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: tsToDate(data['updatedAt']),
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
      confirmedAt: tsToDate(data['confirmedAt']),
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  static DateTime? tsToDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    return null;
  }

  static String _requiredNonEmptyString(
    Map<String, dynamic> data, {
    required String field,
  }) {
    final value = data[field];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw FormatException('Missing or invalid "$field"');
  }

  static int _requiredPositiveInt(
    Map<String, dynamic> data, {
    required String field,
  }) {
    final value = data[field];
    if (value is int && value > 0) {
      return value;
    }
    if (value is num && value > 0 && value == value.roundToDouble()) {
      return value.toInt();
    }
    throw FormatException('Missing or invalid "$field"');
  }

  static bool _requiredBool(
    Map<String, dynamic> data, {
    required String field,
  }) {
    final value = data[field];
    if (value is bool) return value;
    throw FormatException('Missing or invalid "$field"');
  }

  static DateTime _requiredTimestamp(
    Map<String, dynamic> data, {
    required String field,
  }) {
    final value = data[field];
    if (value is Timestamp) return value.toDate();
    throw FormatException('Missing or invalid "$field"');
  }

  static Map<String, String> _requiredNonEmptyStringMap(
    Map<String, dynamic> data, {
    required String field,
  }) {
    final value = data[field];
    if (value is! Map) {
      throw FormatException('Missing or invalid "$field"');
    }

    final result = <String, String>{};
    value.forEach((key, rawValue) {
      if (key is! String || rawValue is! String || rawValue.trim().isEmpty) {
        throw FormatException('Missing or invalid "$field"');
      }
      result[key] = rawValue;
    });

    if (result.isEmpty) {
      throw FormatException('Missing or invalid "$field"');
    }
    return result;
  }

  static T? _parseEnum<T extends Enum>(List<T> values, String? raw) {
    if (raw == null) return null;
    return values.cast<T?>().firstWhere(
      (e) => e?.name == raw,
      orElse: () => null,
    );
  }

  static BookingStatus _parseBookingStatus(dynamic raw) {
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
}
