import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_entity.dart';

/// DTO para serialización/deserialización desde Firestore.
///
/// Campos normativos añadidos (espejo de [ProfileEntity]):
/// [isniCode], [ipiCode], [sgaeRegistered], [taxId], [vatRegistered],
/// [createdAt], [updatedAt], [isPublic], [ageConsent], [nationality].
class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    required this.skills,
    required this.links,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.influences = const {},
    this.availableForHire = false,
    this.isniCode,
    this.ipiCode,
    this.sgaeRegistered = false,
    this.taxId,
    this.vatRegistered = false,
    this.isPublic = true,
    this.ageConsent,
    this.nationality,
  });

  final String id;
  final String name;
  final String bio;
  final String location;
  final List<String> skills;
  final Map<String, String> links;
  final String? photoUrl;
  final Map<String, List<String>> influences;
  final bool availableForHire;

  // ── Normativa ──────────────────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? isniCode;
  final String? ipiCode;
  final bool sgaeRegistered;
  final String? taxId;
  final bool vatRegistered;
  final bool isPublic;
  final bool? ageConsent;
  final String? nationality;

  /// Convierte el mapa de Firestore en un [ProfileDto].
  factory ProfileDto.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProfileDto(
      id: id,
      name: (data['name'] ?? '') as String,
      bio: (data['bio'] ?? '') as String,
      location: (data['city'] ?? '') as String,
      skills: _stringList(data['styles']),
      links: _stringMap(data['links']),
      photoUrl: data['photoUrl'] as String?,
      influences: _influencesMap(data['influences']),
      availableForHire: (data['availableForHire'] as bool?) ?? false,
      // Normativa
      createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(data['updatedAt']) ?? DateTime.now(),
      isniCode: data['isniCode'] as String?,
      ipiCode: data['ipiCode'] as String?,
      sgaeRegistered: (data['sgaeRegistered'] as bool?) ?? false,
      taxId: data['taxId'] as String?,
      vatRegistered: (data['vatRegistered'] as bool?) ?? false,
      isPublic: (data['isPublic'] as bool?) ?? true,
      ageConsent: data['ageConsent'] as bool?,
      nationality: data['nationality'] as String?,
    );
  }

  /// Serializa a mapa para Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'bio': bio,
      'city': location,
      'styles': skills,
      'links': links,
      'photoUrl': photoUrl,
      'influences': influences,
      'availableForHire': availableForHire,
      // Normativa
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isniCode': isniCode,
      'ipiCode': ipiCode,
      'sgaeRegistered': sgaeRegistered,
      'taxId': taxId,
      'vatRegistered': vatRegistered,
      'isPublic': isPublic,
      'ageConsent': ageConsent,
      'nationality': nationality,
    };
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      bio: bio,
      location: location,
      skills: skills,
      links: links,
      photoUrl: photoUrl,
      influences: influences,
      availableForHire: availableForHire,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isniCode: isniCode,
      ipiCode: ipiCode,
      sgaeRegistered: sgaeRegistered,
      taxId: taxId,
      vatRegistered: vatRegistered,
      isPublic: isPublic,
      ageConsent: ageConsent,
      nationality: nationality,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static DateTime? _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return const {};
  }

  static Map<String, List<String>> _influencesMap(dynamic raw) {
    if (raw is! Map) return const {};
    final mapped = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is! Iterable) return;
      final artists = value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (artists.isNotEmpty) mapped[key.toString()] = artists;
    });
    return mapped;
  }
}
