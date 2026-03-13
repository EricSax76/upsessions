import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_entity.dart';
import 'event_enums.dart';

class EventDto {
  EventDto({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.city,
    required this.venue,
    required this.start,
    required this.end,
    required this.description,
    required this.organizer,
    required this.contactEmail,
    required this.contactPhone,
    required this.lineup,
    required this.tags,
    required this.ticketInfo,
    required this.capacity,
    required this.resources,
    required this.isPublic,
    required this.isFree,
    required this.updatedAt,
    required this.status,
    this.notes,
    this.bannerImageUrl,
    this.province,
    this.postalCode,
    this.eventLicenseNumber,
    this.ticketPrice,
    this.vatRate,
    this.ageRestriction,
    this.accessibilityInfo,
    this.cancellationPolicy,
    this.publishedAt,
  });

  factory EventDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return EventDto(
      id: snapshot.id,
      title: (data['title'] as String?) ?? '',
      ownerId: (data['ownerId'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      venue: (data['venue'] as String?) ?? '',
      start: _asDateTime(data['start']),
      end: _asDateTime(data['end']),
      description: (data['description'] as String?) ?? '',
      organizer: (data['organizer'] as String?) ?? '',
      contactEmail: (data['contactEmail'] as String?) ?? '',
      contactPhone: (data['contactPhone'] as String?) ?? '',
      lineup: _stringList(data['lineup']),
      tags: _stringList(data['tags']),
      ticketInfo: (data['ticketInfo'] as String?) ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      resources: _stringList(data['resources']),
      notes: data['notes'] as String?,
      bannerImageUrl: data['bannerImageUrl'] as String?,
      province: data['province'] as String?,
      postalCode: data['postalCode'] as String?,
      eventLicenseNumber: data['eventLicenseNumber'] as String?,
      ticketPrice: (data['ticketPrice'] as num?)?.toDouble(),
      vatRate: (data['vatRate'] as num?)?.toDouble(),
      isPublic: (data['isPublic'] as bool?) ?? true,
      ageRestriction: (data['ageRestriction'] as num?)?.toInt(),
      accessibilityInfo: data['accessibilityInfo'] as String?,
      isFree: (data['isFree'] as bool?) ?? false,
      cancellationPolicy: data['cancellationPolicy'] as String?,
      publishedAt: data['publishedAt'] != null
          ? _asDateTime(data['publishedAt'])
          : null,
      updatedAt: _asDateTime(data['updatedAt']),
      status: _asEventStatus(data['status']),
    );
  }

  factory EventDto.fromEntity(EventEntity entity) {
    return EventDto(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      city: entity.city,
      venue: entity.venue,
      start: entity.start,
      end: entity.end,
      description: entity.description,
      organizer: entity.organizer,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      lineup: entity.lineup,
      tags: entity.tags,
      ticketInfo: entity.ticketInfo,
      capacity: entity.capacity,
      resources: entity.resources,
      notes: entity.notes,
      bannerImageUrl: entity.bannerImageUrl,
      province: entity.province,
      postalCode: entity.postalCode,
      eventLicenseNumber: entity.eventLicenseNumber,
      ticketPrice: entity.ticketPrice,
      vatRate: entity.vatRate,
      isPublic: entity.isPublic,
      ageRestriction: entity.ageRestriction,
      accessibilityInfo: entity.accessibilityInfo,
      isFree: entity.isFree,
      cancellationPolicy: entity.cancellationPolicy,
      publishedAt: entity.publishedAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
    );
  }

  final String id;
  final String ownerId;
  final String title;
  final String city;
  final String venue;
  final DateTime start;
  final DateTime end;
  final String description;
  final String organizer;
  final String contactEmail;
  final String contactPhone;
  final List<String> lineup;
  final List<String> tags;
  final String ticketInfo;
  final int capacity;
  final List<String> resources;
  final String? notes;
  final String? bannerImageUrl;
  final String? province;
  final String? postalCode;
  final String? eventLicenseNumber;
  final double? ticketPrice;
  final double? vatRate;
  final bool isPublic;
  final int? ageRestriction;
  final String? accessibilityInfo;
  final bool isFree;
  final String? cancellationPolicy;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final EventStatus status;

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      city: city,
      venue: venue,
      start: start,
      end: end,
      description: description,
      organizer: organizer,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      lineup: lineup,
      tags: tags,
      ticketInfo: ticketInfo,
      capacity: capacity,
      resources: resources,
      notes: notes,
      bannerImageUrl: bannerImageUrl,
      province: province,
      postalCode: postalCode,
      eventLicenseNumber: eventLicenseNumber,
      ticketPrice: ticketPrice,
      vatRate: vatRate,
      isPublic: isPublic,
      ageRestriction: ageRestriction,
      accessibilityInfo: accessibilityInfo,
      isFree: isFree,
      cancellationPolicy: cancellationPolicy,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'city': city,
      'venue': venue,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'description': description,
      'organizer': organizer,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'lineup': lineup,
      'tags': tags,
      'ticketInfo': ticketInfo,
      'capacity': capacity,
      'resources': resources,
      'isPublic': isPublic,
      'isFree': isFree,
      'status': status.name,
      if (notes != null) 'notes': notes,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (province != null) 'province': province,
      if (postalCode != null) 'postalCode': postalCode,
      if (eventLicenseNumber != null) 'eventLicenseNumber': eventLicenseNumber,
      if (ticketPrice != null) 'ticketPrice': ticketPrice,
      if (vatRate != null) 'vatRate': vatRate,
      if (ageRestriction != null) 'ageRestriction': ageRestriction,
      if (accessibilityInfo != null) 'accessibilityInfo': accessibilityInfo,
      if (cancellationPolicy != null) 'cancellationPolicy': cancellationPolicy,
      if (publishedAt != null) 'publishedAt': Timestamp.fromDate(publishedAt!),
    };
  }
}

DateTime _asDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

List<String> _stringList(dynamic value) {
  if (value is Iterable) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

EventStatus _asEventStatus(dynamic value) {
  if (value is String) {
    return EventStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventStatus.draft,
    );
  }
  return EventStatus.draft;
}
