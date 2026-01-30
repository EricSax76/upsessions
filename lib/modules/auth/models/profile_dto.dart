import 'profile_entity.dart';

class ProfileDto {
  const ProfileDto({
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

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      bio: bio,
      location: location,
      skills: skills,
      links: links,
      photoUrl: photoUrl,
    );
  }
}
