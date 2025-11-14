import 'package:flutter/foundation.dart';

@immutable
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    required this.skills,
    required this.links,
  });

  final String id;
  final String name;
  final String bio;
  final String location;
  final List<String> skills;
  final Map<String, String> links;

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? bio,
    String? location,
    List<String>? skills,
    Map<String, String>? links,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      links: links ?? this.links,
    );
  }
}
