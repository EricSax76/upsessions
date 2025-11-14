import 'dart:async';

import 'profile_dto.dart';

class ProfileRepository {
  Future<ProfileDto> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const ProfileDto(
      id: 'profile-1',
      name: 'Solista Demo',
      bio: 'Cantante y compositora con experiencia en festivales nacionales.',
      location: 'CDMX',
      skills: ['Voz', 'Composición', 'Producción'],
      links: {'Instagram': 'https://instagram.com/solista', 'YouTube': 'youtube.com/solista'},
    );
  }
}
