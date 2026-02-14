import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/profile_entity.dart';
import '../models/auth_exceptions.dart';
import 'auth_repository.dart';
import '../models/profile_dto.dart';

class ProfileRepository {
  ProfileRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _authRepository = authRepository,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final FirebaseStorage _storage;

  Future<ProfileDto> fetchProfile({String? profileId}) async {
    final id = profileId ?? _authRepository.currentUser?.id;
    if (id == null) {
      throw AuthException('Debes iniciar sesión para cargar tu perfil.');
    }

    final collection = _firestore.collection('musicians');
    DocumentSnapshot<Map<String, dynamic>>? doc;
    final directDoc = await collection.doc(id).get();
    if (directDoc.exists) {
      doc = directDoc;
    } else {
      final query = await collection
          .where('ownerId', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        doc = query.docs.first;
      }
    }
    if (doc == null) {
      throw Exception('Perfil no encontrado.');
    }
    final resolvedDoc = doc;
    final data = resolvedDoc.data() ?? <String, dynamic>{};
    return ProfileDto(
      id: resolvedDoc.id,
      name: (data['name'] ?? '') as String,
      bio: (data['bio'] ?? '') as String,
      location: (data['city'] ?? '') as String,
      skills: _stringList(data['styles']),
      links: _stringMap(data['links']),
      photoUrl: data['photoUrl'] as String?,
      influences: _influencesMap(data['influences']),
    );
  }

  Future<ProfileDto> updateProfile(ProfileEntity profile) async {
    final data = {
      'name': profile.name,
      'bio': profile.bio,
      'city': profile.location,
      'styles': profile.skills,
      'links': profile.links,
      'photoUrl': profile.photoUrl,
      'influences': profile.influences,
    };
    await _firestore
        .collection('musicians')
        .doc(profile.id)
        .set(data, SetOptions(merge: true));
    return ProfileDto(
      id: profile.id,
      name: profile.name,
      bio: profile.bio,
      location: profile.location,
      skills: profile.skills,
      links: profile.links,
      photoUrl: profile.photoUrl,
      influences: profile.influences,
    );
  }

  Future<ProfileDto> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = _normalizeExtension(fileExtension);
    final ref = _storage
        .ref()
        .child('profiles')
        .child(userId)
        .child('profile.$ext');
    final metadata = SettableMetadata(contentType: 'image/$ext');
    await ref.putData(bytes, metadata);
    final downloadUrl = await ref.getDownloadURL();
    final musicianDocId = await _locateMusicianDocId(userId);
    await _firestore.collection('musicians').doc(musicianDocId).set({
      'photoUrl': downloadUrl,
    }, SetOptions(merge: true));
    return fetchProfile(profileId: userId);
  }

  Future<String> _locateMusicianDocId(String userId) async {
    final directDoc = await _firestore
        .collection('musicians')
        .doc(userId)
        .get();
    if (directDoc.exists) {
      return directDoc.id;
    }
    final query = await _firestore
        .collection('musicians')
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Perfil no encontrado.');
    }
    return query.docs.first.id;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((element) => element.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return const {};
  }

  static Map<String, List<String>> _influencesMap(dynamic raw) {
    if (raw is! Map) {
      return const {};
    }
    final mapped = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is! Iterable) {
        return;
      }
      final artists = value
          .map((element) => element.toString().trim())
          .where((element) => element.isNotEmpty)
          .toList();
      if (artists.isNotEmpty) {
        mapped[key.toString()] = artists;
      }
    });
    return mapped;
  }

  static String _normalizeExtension(String input) {
    final normalized = input.toLowerCase().replaceAll('.', '');
    if (normalized.isEmpty) {
      return 'jpeg';
    }
    switch (normalized) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
      case 'gif':
      case 'webp':
        return normalized;
      default:
        return 'jpeg';
    }
  }
}
