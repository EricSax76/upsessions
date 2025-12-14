import 'package:flutter/foundation.dart';

@immutable
class MusicianEntity {
  const MusicianEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.instrument,
    required this.city,
    required this.styles,
    required this.experienceYears,
    this.photoUrl,
  });

  final String id;
  final String ownerId;
  final String name;
  final String instrument;
  final String city;
  final List<String> styles;
  final int experienceYears;
  final String? photoUrl;
}
