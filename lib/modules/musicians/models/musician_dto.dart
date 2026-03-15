import 'package:cloud_firestore/cloud_firestore.dart';

import 'musician_compliance_info.dart';
import 'musician_dto_parsers.dart';
import 'musician_entity.dart';
import 'musician_professional_info.dart';

/// DTO para serialización/deserialización de [MusicianEntity] desde Firestore.
///
/// Campos normativos añadidos (espejo de [MusicianEntity]):
/// [updatedAt], [deletedAt], [isVerifiedArtist], [languages],
/// [workRadius], [minimumFee], [hasPublicLiabilityInsurance], [unionMembership],
/// [birthDate], [legalGuardianEmail], [legalGuardianConsent], [legalGuardianConsentAt], [ageConsent].
class MusicianDto {
  const MusicianDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.instrument,
    required this.city,
    required this.styles,
    required this.experienceYears,
    required this.updatedAt,
    this.photoUrl,
    this.province,
    this.profileType,
    this.gender,
    this.rating,
    this.bio = '',
    this.links = const {},
    this.influences = const {},
    this.availableForHire = false,
    // ── Normativa ───────────────────────────────────────────────────────────
    this.isVerifiedArtist = false,
    this.languages = const [],
    this.workRadius,
    this.minimumFee,
    this.hasPublicLiabilityInsurance = false,
    this.unionMembership,
    this.birthDate,
    this.legalGuardianEmail,
    this.legalGuardianConsent = false,
    this.legalGuardianConsentAt,
    this.ageConsent,
    this.deletedAt,
  });

  factory MusicianDto.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final stylesDynamic = data['styles'];
    return MusicianDto(
      id: doc.id,
      ownerId: (data['ownerId'] ?? doc.id).toString(),
      name: (data['name'] ?? '') as String,
      instrument: (data['instrument'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      styles: stylesDynamic is Iterable
          ? List<String>.from(stylesDynamic)
          : const <String>[],
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      photoUrl: firstNonEmptyString([
        data['photoUrl'],
        data['photoURL'],
        data['imageUrl'],
        data['avatarUrl'],
      ]),
      province: data['province'] as String?,
      profileType: data['profileType'] as String?,
      gender: data['gender'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      bio: (data['bio'] ?? '') as String,
      links:
          (data['links'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          const {},
      influences:
          (data['influences'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => e.toString()).toList(),
            ),
          ) ??
          const {},
      availableForHire: (data['availableForHire'] as bool?) ?? false,
      // ── Normativa ─────────────────────────────────────────────────────────
      updatedAt: toDateTime(data['updatedAt']) ?? DateTime.now(),
      deletedAt: toDateTime(data['deletedAt']),
      isVerifiedArtist: (data['isVerifiedArtist'] as bool?) ?? false,
      languages: toStringList(data['languages']),
      workRadius: (data['workRadius'] as num?)?.toInt(),
      minimumFee: (data['minimumFee'] as num?)?.toDouble(),
      hasPublicLiabilityInsurance:
          (data['hasPublicLiabilityInsurance'] as bool?) ?? false,
      unionMembership: data['unionMembership'] as String?,
      birthDate: toDateTime(data['birthDate']),
      legalGuardianEmail: data['legalGuardianEmail'] as String?,
      legalGuardianConsent: (data['legalGuardianConsent'] as bool?) ?? false,
      legalGuardianConsentAt: toDateTime(data['legalGuardianConsentAt']),
      ageConsent: data['ageConsent'] as bool?,
    );
  }

  // ── Campos existentes ─────────────────────────────────────────────────────
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

  // ── Normativa ─────────────────────────────────────────────────────────────
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isVerifiedArtist;
  final List<String> languages;
  final int? workRadius;
  final double? minimumFee;
  final bool hasPublicLiabilityInsurance;
  final String? unionMembership;
  final DateTime? birthDate;
  final String? legalGuardianEmail;
  final bool legalGuardianConsent;
  final DateTime? legalGuardianConsentAt;
  final bool? ageConsent;

  /// Serializa a mapa para Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'instrument': instrument,
      'city': city,
      'styles': styles,
      'experienceYears': experienceYears,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (province != null) 'province': province,
      if (profileType != null) 'profileType': profileType,
      if (gender != null) 'gender': gender,
      if (rating != null) 'rating': rating,
      'bio': bio,
      'links': links,
      'influences': influences,
      'availableForHire': availableForHire,
      // Normativa
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
      'isVerifiedArtist': isVerifiedArtist,
      'languages': languages,
      if (workRadius != null) 'workRadius': workRadius,
      if (minimumFee != null) 'minimumFee': minimumFee,
      'hasPublicLiabilityInsurance': hasPublicLiabilityInsurance,
      if (unionMembership != null) 'unionMembership': unionMembership,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      'legalGuardianEmail': legalGuardianEmail,
      'legalGuardianConsent': legalGuardianConsent,
      if (legalGuardianConsentAt != null)
        'legalGuardianConsentAt': Timestamp.fromDate(legalGuardianConsentAt!),
      'ageConsent': ageConsent,
    };
  }

  MusicianEntity toEntity() {
    return MusicianEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      instrument: instrument,
      city: city,
      styles: styles,
      experienceYears: experienceYears,
      photoUrl: photoUrl,
      province: province,
      profileType: profileType,
      gender: gender,
      rating: rating,
      bio: bio,
      links: links,
      influences: influences,
      availableForHire: availableForHire,
      compliance: MusicianComplianceInfo(
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        isVerifiedArtist: isVerifiedArtist,
        birthDate: birthDate,
        legalGuardianEmail: legalGuardianEmail,
        legalGuardianConsent: legalGuardianConsent,
        legalGuardianConsentAt: legalGuardianConsentAt,
        ageConsent: ageConsent,
      ),
      professional: MusicianProfessionalInfo(
        languages: languages,
        workRadius: workRadius,
        minimumFee: minimumFee,
        hasPublicLiabilityInsurance: hasPublicLiabilityInsurance,
        unionMembership: unionMembership,
      ),
    );
  }

}
