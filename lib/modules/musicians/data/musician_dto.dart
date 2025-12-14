import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/musician_entity.dart';

class MusicianDto {
  const MusicianDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.instrument,
    required this.city,
    required this.styles,
    required this.experienceYears,
    this.photoUrl,
  });

  factory MusicianDto.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final stylesDynamic = data['styles'];
    return MusicianDto(
      id: doc.id,
      ownerId: (data['ownerId'] ?? doc.id).toString(),
      name: (data['name'] ?? '') as String,
      instrument: (data['instrument'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      styles: stylesDynamic is Iterable ? List<String>.from(stylesDynamic) : const <String>[],
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  final String id;
  final String ownerId;
  final String name;
  final String instrument;
  final String city;
  final List<String> styles;
  final int experienceYears;
  final String? photoUrl;

  MusicianEntity toEntity() {
    return MusicianEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      instrument: instrument,
      city: city,
      styles: styles,
      experienceYears: experienceYears,
      photoUrl: photoUrl,
    );
  }
}
