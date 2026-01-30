import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProfileEntity extends Equatable {
  static const Object _unset = Object();

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    required this.skills,
    required this.links,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String bio;
  final String location;
  final List<String> skills;
  final Map<String, String> links;
  final String? photoUrl;

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? bio,
    String? location,
    List<String>? skills,
    Map<String, String>? links,
    Object? photoUrl = _unset,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      links: links ?? this.links,
      photoUrl: identical(photoUrl, _unset) ? this.photoUrl : photoUrl as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, bio, location, skills, links, photoUrl];
}
