import 'package:cloud_firestore/cloud_firestore.dart';
import 'jam_session_entity.dart';

class JamSessionDto {
  const JamSessionDto({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.city,
    this.coverImageUrl,
    required this.instrumentRequirements,
    required this.isCanceled,
    // Normativa
    this.province,
    this.maxAttendees,
    this.isPublic = true,
    this.venueId,
    this.entryFee,
    this.ageRestriction,
    this.createdAt,
    this.updatedAt,
    this.attendees = const [],
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final Timestamp? date;
  final String time;
  final String location;
  final String city;
  final String? coverImageUrl;
  final List<String> instrumentRequirements;
  final bool isCanceled;

  // Normativa
  final String? province;
  final int? maxAttendees;
  final bool isPublic;
  final String? venueId;
  final double? entryFee;
  final int? ageRestriction;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final List<String> attendees;

  factory JamSessionDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return JamSessionDto(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: data['date'] as Timestamp?,
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      city: data['city'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      instrumentRequirements:
          List<String>.from(data['instrumentRequirements'] ?? []),
      isCanceled: data['isCanceled'] as bool? ?? false,
      // Normativa
      province: data['province'] as String?,
      maxAttendees: (data['maxAttendees'] as num?)?.toInt(),
      isPublic: data['isPublic'] as bool? ?? true,
      venueId: data['venueId'] as String?,
      entryFee: (data['entryFee'] as num?)?.toDouble(),
      ageRestriction: (data['ageRestriction'] as num?)?.toInt(),
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  factory JamSessionDto.fromEntity(JamSessionEntity entity) {
    return JamSessionDto(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      description: entity.description,
      date: entity.date != null ? Timestamp.fromDate(entity.date!) : null,
      time: entity.time,
      location: entity.location,
      city: entity.city,
      coverImageUrl: entity.coverImageUrl,
      instrumentRequirements: entity.instrumentRequirements,
      isCanceled: entity.isCanceled,
      // Normativa
      province: entity.province,
      maxAttendees: entity.maxAttendees,
      isPublic: entity.isPublic,
      venueId: entity.venueId,
      entryFee: entity.entryFee,
      ageRestriction: entity.ageRestriction,
      createdAt:
          entity.createdAt != null ? Timestamp.fromDate(entity.createdAt!) : null,
      updatedAt:
          entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
      attendees: entity.attendees,
    );
  }

  JamSessionEntity toEntity() {
    return JamSessionEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: description,
      date: date?.toDate(),
      time: time,
      location: location,
      city: city,
      coverImageUrl: coverImageUrl,
      instrumentRequirements: instrumentRequirements,
      isCanceled: isCanceled,
      // Normativa
      province: province,
      maxAttendees: maxAttendees,
      isPublic: isPublic,
      venueId: venueId,
      entryFee: entryFee,
      ageRestriction: ageRestriction,
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
      attendees: attendees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      if (date != null) 'date': date,
      'time': time,
      'location': location,
      'city': city,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'instrumentRequirements': instrumentRequirements,
      'isCanceled': isCanceled,
      // Normativa
      if (province != null) 'province': province,
      if (maxAttendees != null) 'maxAttendees': maxAttendees,
      'isPublic': isPublic,
      if (venueId != null) 'venueId': venueId,
      if (entryFee != null) 'entryFee': entryFee,
      if (ageRestriction != null) 'ageRestriction': ageRestriction,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (attendees.isNotEmpty) 'attendees': attendees,
    };
  }
}
