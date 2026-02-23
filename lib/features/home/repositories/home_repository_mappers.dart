import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:upsessions/features/home/models/home_event_model.dart';
import 'package:upsessions/modules/musicians/models/musician_dto.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';

class HomeRepositoryMappers {
  const HomeRepositoryMappers._();

  static MusicianEntity musicianFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return MusicianDto.fromDocument(doc).toEntity();
  }

  static HomeEventModel eventFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return HomeEventModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      venue: (data['venue'] ?? '') as String,
      start: parseTimestamp(data['start']),
      description: (data['description'] ?? '') as String,
      organizer: (data['organizer'] ?? '') as String,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      ticketInfo: (data['ticketInfo'] ?? '') as String,
      tags: stringList(data['tags']),
      bannerImageUrl: data['bannerImageUrl'] as String?,
    );
  }

  static RehearsalEntity rehearsalFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String groupId,
  }) {
    final data = doc.data();
    final startsAt =
        (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endsAt = (data['endsAt'] as Timestamp?)?.toDate();
    return RehearsalEntity(
      id: doc.id,
      groupId: groupId,
      startsAt: startsAt,
      endsAt: endsAt,
      location: (data['location'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
    );
  }

  static DateTime parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static List<String> stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
