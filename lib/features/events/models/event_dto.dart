import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_entity.dart';

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
    this.notes,
    this.bannerImageUrl,
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
      if (notes != null) 'notes': notes,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
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
