import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/data/auth_exceptions.dart';
import '../../auth/data/auth_repository.dart';
import 'profile_dto.dart';

class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore, AuthRepository? authRepository})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  Future<ProfileDto> fetchProfile({String? profileId}) async {
    final id = profileId ?? _authRepository.currentUser?.id;
    if (id == null) {
      throw AuthException('Debes iniciar sesión para cargar tu perfil.');
    }
    final doc = await _firestore.collection('profiles').doc(id).get();
    if (!doc.exists) {
      throw Exception('Perfil no encontrado.');
    }
    final data = doc.data() ?? <String, dynamic>{};
    return ProfileDto(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      bio: (data['bio'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      skills: _stringList(data['skills']),
      links: _stringMap(data['links']),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((element) => element.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return const {};
  }
}
