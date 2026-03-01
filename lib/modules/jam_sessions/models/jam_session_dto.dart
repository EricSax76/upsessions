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
      instrumentRequirements: List<String>.from(data['instrumentRequirements'] ?? []),
      isCanceled: data['isCanceled'] as bool? ?? false,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'city': city,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'instrumentRequirements': instrumentRequirements,
      'isCanceled': isCanceled,
    };
  }
}
