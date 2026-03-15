import 'package:flutter/foundation.dart';

/// Datos normativos del músico: RGPD, soft-delete y tutela legal de menores.
///
/// - [updatedAt]             → RGPD Art. 5.1.d — exactitud; política de caducidad
/// - [deletedAt]             → RGPD Art. 17 — soft-delete; derecho al olvido
/// - [isVerifiedArtist]      → Confianza / protección del consumidor
/// - [birthDate]             → LOPDGDD Art. 7 — verificación de edad mínima (14+)
/// - [legalGuardianEmail]    → LOPDGDD Art. 7 — contacto del tutor legal
/// - [legalGuardianConsent]  → LOPDGDD Art. 7 — constancia del consentimiento
/// - [legalGuardianConsentAt]→ LOPDGDD Art. 7 — fecha de registro del consentimiento
/// - [ageConsent]            → LOPDGDD Art. 7 — marca de control de edad mínima
@immutable
class MusicianComplianceInfo {
  const MusicianComplianceInfo({
    required this.updatedAt,
    this.deletedAt,
    this.isVerifiedArtist = false,
    this.birthDate,
    this.legalGuardianEmail,
    this.legalGuardianConsent = false,
    this.legalGuardianConsentAt,
    this.ageConsent,
  });

  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isVerifiedArtist;
  final DateTime? birthDate;
  final String? legalGuardianEmail;
  final bool legalGuardianConsent;
  final DateTime? legalGuardianConsentAt;
  final bool? ageConsent;

  /// `true` cuando el perfil no ha sido borrado con soft-delete.
  bool get isActive => deletedAt == null;

  MusicianComplianceInfo copyWith({
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isVerifiedArtist,
    DateTime? birthDate,
    String? legalGuardianEmail,
    bool? legalGuardianConsent,
    DateTime? legalGuardianConsentAt,
    bool? ageConsent,
  }) {
    return MusicianComplianceInfo(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isVerifiedArtist: isVerifiedArtist ?? this.isVerifiedArtist,
      birthDate: birthDate ?? this.birthDate,
      legalGuardianEmail: legalGuardianEmail ?? this.legalGuardianEmail,
      legalGuardianConsent: legalGuardianConsent ?? this.legalGuardianConsent,
      legalGuardianConsentAt:
          legalGuardianConsentAt ?? this.legalGuardianConsentAt,
      ageConsent: ageConsent ?? this.ageConsent,
    );
  }
}
