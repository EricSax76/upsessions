import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/spanish_geography.dart';
import '../models/musician_entity.dart';
import '../models/musician_dto.dart';

class MusiciansRepository {
  MusiciansRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collectionName = 'musicians';

  Future<List<MusicianEntity>> search({
    String query = '',
    int limit = 50,
    String instrument = '',
    String style = '',
    String province = '',
    String city = '',
    String profileType = '',
    String gender = '',
  }) async {
    final normalizedQuery = _normalize(query);
    final normalizedInstrument = _normalize(instrument);
    final normalizedStyle = _normalize(style);
    final normalizedProvince = _normalize(province);
    final normalizedCity = _normalize(city);
    final normalizedProfileType = _normalize(profileType);
    final normalizedGender = _normalize(gender);
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('name')
        .limit(limit)
        .get();
    final musicians = snapshot.docs
        .map(MusicianDto.fromDocument)
        .map((dto) => dto.toEntity())
        .toList();
    if (normalizedQuery.isEmpty &&
        normalizedInstrument.isEmpty &&
        normalizedStyle.isEmpty &&
        normalizedProvince.isEmpty &&
        normalizedCity.isEmpty &&
        normalizedProfileType.isEmpty &&
        normalizedGender.isEmpty) {
      return musicians;
    }

    List<String> provinceCities = const [];
    if (normalizedProvince.isNotEmpty) {
      provinceCities = await _fetchCitiesForProvince(province);
    }

    return musicians.where((musician) {
      if (normalizedQuery.isNotEmpty &&
          !_matchesQuery(musician, normalizedQuery)) {
        return false;
      }
      if (normalizedInstrument.isNotEmpty &&
          !_matchesValue(musician.instrument, normalizedInstrument)) {
        return false;
      }
      if (normalizedStyle.isNotEmpty &&
          !musician.styles.any(
            (style) => _matchesValue(style, normalizedStyle),
          )) {
        return false;
      }
      if (normalizedCity.isNotEmpty &&
          !_matchesValue(musician.city, normalizedCity)) {
        return false;
      }
      if (normalizedProvince.isNotEmpty &&
          !_matchesProvince(musician, normalizedProvince, provinceCities)) {
        return false;
      }
      if (normalizedProfileType.isNotEmpty &&
          !_matchesValue(musician.profileType ?? '', normalizedProfileType)) {
        return false;
      }
      if (normalizedGender.isNotEmpty &&
          normalizedGender != 'cualquiera' &&
          !_matchesValue(musician.gender ?? '', normalizedGender)) {
        return false;
      }
      return true;
    }).toList();
  }

  String _normalize(String value) => value.trim().toLowerCase();

  bool _matchesValue(String value, String normalizedQuery) {
    return _normalize(value).contains(normalizedQuery);
  }

  bool _matchesQuery(MusicianEntity musician, String normalizedQuery) {
    return _matchesValue(musician.name, normalizedQuery) ||
        _matchesValue(musician.instrument, normalizedQuery) ||
        _matchesValue(musician.city, normalizedQuery) ||
        musician.styles.any((style) => _matchesValue(style, normalizedQuery));
  }

  bool _matchesProvince(
    MusicianEntity musician,
    String normalizedProvince,
    List<String> provinceCities,
  ) {
    final musicianProvince = musician.province ?? '';
    if (musicianProvince.trim().isNotEmpty) {
      return _normalize(musicianProvince) == normalizedProvince;
    }
    if (provinceCities.isEmpty) {
      return true;
    }
    final musicianCity = _normalize(musician.city);
    return provinceCities.map(_normalize).any((city) => city == musicianCity);
  }

  Future<List<String>> _fetchCitiesForProvince(String province) async {
    final doc = await _firestore.collection('metadata').doc('geography').get();
    final fallback = spanishCitiesByProvince[province] ?? const [];
    if (!doc.exists) {
      return fallback;
    }
    final data = doc.data();
    final byProvince = data?['citiesByProvince'];
    if (byProvince is Map<String, dynamic>) {
      final cities = byProvince[province];
      final resolved = _stringList(cities);
      return resolved.isNotEmpty ? resolved : fallback;
    }
    return fallback;
  }

  List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  Future<MusicianEntity?> findById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return MusicianDto.fromDocument(doc).toEntity();
  }

  Future<bool> hasProfile(String musicianId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .doc(musicianId)
        .get();
    if (!snapshot.exists) {
      return false;
    }
    final data = snapshot.data() ?? <String, dynamic>{};
    return (data['name'] as String?)?.isNotEmpty == true &&
        (data['instrument'] as String?)?.isNotEmpty == true;
  }

  Future<void> saveProfile({
    required String musicianId,
    required String name,
    required String instrument,
    required String city,
    required List<String> styles,
    required int experienceYears,
    String? photoUrl,
    String? bio,
    String? province,
    String? profileType,
    String? gender,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection(_collectionName).doc(musicianId).set({
      'name': name,
      'instrument': instrument,
      'city': city,
      'styles': styles,
      'experienceYears': experienceYears,
      'photoUrl': photoUrl,
      'bio': bio ?? '',
      'rating': 5.0,
      if (province != null) 'province': province,
      if (profileType != null) 'profileType': profileType,
      if (gender != null) 'gender': gender,
      'ownerId': musicianId,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}
