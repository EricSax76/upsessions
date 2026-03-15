import 'package:flutter/foundation.dart';

import 'musician_compliance_info.dart';
import 'musician_professional_info.dart';

/// Entidad pública del músico — ficha visible en el directorio.
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
    required this.compliance,
    required this.professional,
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

  // ── Campos core ───────────────────────────────────────────────────────────
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

  // ── Normativa / profesional ────────────────────────────────────────────────
  final MusicianComplianceInfo compliance;
  final MusicianProfessionalInfo professional;

  /// Indica si el perfil está activo (no borrado con soft-delete).
  bool get isActive => compliance.isActive;

  MusicianEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? instrument,
    String? city,
    List<String>? styles,
    int? experienceYears,
    String? photoUrl,
    String? province,
    String? profileType,
    String? gender,
    double? rating,
    String? bio,
    Map<String, String>? links,
    Map<String, List<String>>? influences,
    bool? availableForHire,
    MusicianComplianceInfo? compliance,
    MusicianProfessionalInfo? professional,
  }) {
    return MusicianEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      instrument: instrument ?? this.instrument,
      city: city ?? this.city,
      styles: styles ?? this.styles,
      experienceYears: experienceYears ?? this.experienceYears,
      photoUrl: photoUrl ?? this.photoUrl,
      province: province ?? this.province,
      profileType: profileType ?? this.profileType,
      gender: gender ?? this.gender,
      rating: rating ?? this.rating,
      bio: bio ?? this.bio,
      links: links ?? this.links,
      influences: influences ?? this.influences,
      availableForHire: availableForHire ?? this.availableForHire,
      compliance: compliance ?? this.compliance,
      professional: professional ?? this.professional,
    );
  }
}
