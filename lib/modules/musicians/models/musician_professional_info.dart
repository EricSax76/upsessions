import 'package:flutter/foundation.dart';

/// Datos contractuales y profesionales del músico.
///
/// - [languages]                    → Estándar profesional (eventos internacionales, riders técnicos)
/// - [workRadius]                   → Práctico / contractual — km máximos de desplazamiento
/// - [minimumFee]                   → RD 1434/1992 — caché mínima del artista
/// - [hasPublicLiabilityInsurance]  → Reglamento de espectáculos públicos — seguro RC obligatorio
/// - [unionMembership]              → Estándar profesional — sindicato (UME, MUSICAE, etc.)
@immutable
class MusicianProfessionalInfo {
  const MusicianProfessionalInfo({
    this.languages = const [],
    this.workRadius,
    this.minimumFee,
    this.hasPublicLiabilityInsurance = false,
    this.unionMembership,
  });

  /// Idiomas del artista (BCP 47); relevante para eventos internacionales.
  final List<String> languages;

  /// Kilómetros máximos de desplazamiento; clave en contratos de bolos.
  final int? workRadius;

  /// RD 1434/1992 — caché mínima del artista; transparencia económica.
  final double? minimumFee;

  /// Muchos venues exigen seguro de responsabilidad civil al artista.
  final bool hasPublicLiabilityInsurance;

  /// Sindicato al que pertenece (UME, MUSICAE, etc.).
  final String? unionMembership;

  MusicianProfessionalInfo copyWith({
    List<String>? languages,
    int? workRadius,
    double? minimumFee,
    bool? hasPublicLiabilityInsurance,
    String? unionMembership,
  }) {
    return MusicianProfessionalInfo(
      languages: languages ?? this.languages,
      workRadius: workRadius ?? this.workRadius,
      minimumFee: minimumFee ?? this.minimumFee,
      hasPublicLiabilityInsurance:
          hasPublicLiabilityInsurance ?? this.hasPublicLiabilityInsurance,
      unionMembership: unionMembership ?? this.unionMembership,
    );
  }
}
