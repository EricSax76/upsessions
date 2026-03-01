import 'package:cloud_firestore/cloud_firestore.dart';

import 'musician_entity.dart';

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
    this.province,
    this.profileType,
    this.gender,
    this.rating,
    this.bio = '',
    this.links = const {},
    this.influences = const {},
    this.availableForHire = false,
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
      styles: stylesDynamic is Iterable
          ? List<String>.from(stylesDynamic)
          : const <String>[],
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      photoUrl: data['photoUrl'] as String?,
      province: data['province'] as String?,
      profileType: data['profileType'] as String?,
      gender: data['gender'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      bio: (data['bio'] ?? '') as String,
      links:
          (data['links'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          const {},
      influences:
          (data['influences'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList(),
            ),
          ) ??
          const {},
      availableForHire: (data['availableForHire'] as bool?) ?? false,
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
  final String? province;
  final String? profileType;
  final String? gender;
  final double? rating;
  final String bio;
  final Map<String, String> links;
  final Map<String, List<String>> influences;
  final bool availableForHire;

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
      province: province,
      profileType: profileType,
      gender: gender,
      rating: rating,
      bio: bio,
      links: links,
      influences: influences,
      availableForHire: availableForHire,
    );
  }
}
