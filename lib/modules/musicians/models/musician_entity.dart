import 'package:flutter/foundation.dart';

/// Entidad pública del músico — ficha visible en el directorio.
///
/// Campos normativos añadidos:
/// - [updatedAt]                   → RGPD Art. 5.1.d — exactitud del dato; política de caducidad
/// - [deletedAt]                   → RGPD Art. 17 — soft-delete para cumplimiento del derecho al olvido
/// - [isVerifiedArtist]            → Confianza / protección del consumidor
/// - [languages]                   → Estándar profesional (eventos internacionales, riders técnicos)
/// - [workRadius]                  → Práctico / contractual — km máximos de desplazamiento
/// - [minimumFee]                  → RD 1434/1992 / negociación — caché mínima del artista
/// - [hasPublicLiabilityInsurance] → Reglamento de espectáculos públicos — seguro RC obligatorio en venues
/// - [unionMembership]             → Estándar profesional — sindicato (UME, MUSICAE, etc.)
/// - [birthDate]                   → LOPDGDD Art. 7 — verificación de edad mínima (14+)
/// - [legalGuardianEmail]          → LOPDGDD Art. 7 — contacto del tutor legal para menores
/// - [legalGuardianConsent]        → LOPDGDD Art. 7 — constancia de consentimiento del tutor
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
    // ── Normativa ────────────────────────────────────────────────────────────
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

  // ── Normativa RGPD ────────────────────────────────────────────────────────
  /// RGPD Art. 5.1.d — fecha de última modificación del perfil.
  final DateTime updatedAt;

  /// RGPD Art. 17 — soft-delete con TTL; perfil no borrado físicamente.
  final DateTime? deletedAt;

  // ── Confianza / protección del consumidor ─────────────────────────────────
  /// Perfil verificado por la plataforma; reduce fraude en contrataciones.
  final bool isVerifiedArtist;

  // ── Estándar profesional ──────────────────────────────────────────────────
  /// Idiomas del artista (BCP 47); relevante para eventos internacionales.
  final List<String> languages;

  // ── Contractual / negociación ─────────────────────────────────────────────
  /// Kilómetros máximos de desplazamiento; clave en contratos de bolos.
  final int? workRadius;

  /// RD 1434/1992 — caché mínima del artista; transparencia económica.
  final double? minimumFee;

  // ── Reglamento espectáculos públicos ──────────────────────────────────────
  /// Muchos venues exigen seguro de responsabilidad civil al artista.
  final bool hasPublicLiabilityInsurance;

  /// Sindicato al que pertenece (UME, MUSICAE, etc.).
  final String? unionMembership;

  /// LOPDGDD Art. 7 — fecha de nacimiento para validación 14+.
  final DateTime? birthDate;

  /// LOPDGDD Art. 7 — email del tutor legal para menores.
  final String? legalGuardianEmail;

  /// LOPDGDD Art. 7 — confirma consentimiento del tutor legal.
  final bool legalGuardianConsent;

  /// LOPDGDD Art. 7 — fecha de registro del consentimiento del tutor.
  final DateTime? legalGuardianConsentAt;

  /// LOPDGDD Art. 7 — marca de control de edad mínima.
  final bool? ageConsent;

  /// Indica si el perfil está activo (no borrado con soft-delete).
  bool get isActive => deletedAt == null;

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
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isVerifiedArtist,
    List<String>? languages,
    int? workRadius,
    double? minimumFee,
    bool? hasPublicLiabilityInsurance,
    String? unionMembership,
    DateTime? birthDate,
    String? legalGuardianEmail,
    bool? legalGuardianConsent,
    DateTime? legalGuardianConsentAt,
    bool? ageConsent,
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
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isVerifiedArtist: isVerifiedArtist ?? this.isVerifiedArtist,
      languages: languages ?? this.languages,
      workRadius: workRadius ?? this.workRadius,
      minimumFee: minimumFee ?? this.minimumFee,
      hasPublicLiabilityInsurance:
          hasPublicLiabilityInsurance ?? this.hasPublicLiabilityInsurance,
      unionMembership: unionMembership ?? this.unionMembership,
      birthDate: birthDate ?? this.birthDate,
      legalGuardianEmail: legalGuardianEmail ?? this.legalGuardianEmail,
      legalGuardianConsent: legalGuardianConsent ?? this.legalGuardianConsent,
      legalGuardianConsentAt:
          legalGuardianConsentAt ?? this.legalGuardianConsentAt,
      ageConsent: ageConsent ?? this.ageConsent,
    );
  }
}
