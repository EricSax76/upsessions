import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Entidad del perfil público del músico.
///
/// Campos normativos añadidos:
/// - [isniCode]       → ISO 27729 / SGAE — identificador internacional de artista (ISNI)
/// - [ipiCode]        → CISAC / SGAE — código IPI/CAE para compositores e intérpretes
/// - [sgaeRegistered] → RD 1434/1992 — inscripción en sociedad de gestión
/// - [taxId]          → AEAT / Ley 58/2003 — NIF/NIE para facturación y retenciones IRPF
/// - [vatRegistered]  → LIVA / AEAT — alta en el IAE como actividad económica artística
/// - [createdAt]      → RGPD Art. 30 — trazabilidad del ciclo de vida del dato
/// - [updatedAt]      → RGPD Art. 5.1.d — exactitud del dato; política de caducidad
/// - [isPublic]       → RGPD Art. 5.1.b — minimización: perfil público vs. datos internos
/// - [ageConsent]     → LOPDGDD Art. 7 — verificación de mayoría de edad (mín. 14 años)
/// - [nationality]    → RD 1434/1992 Art. 3 — para contratos artísticos y permisos de trabajo
@immutable
class ProfileEntity extends Equatable {
  static const Object _unset = Object();

  const ProfileEntity({
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
    // ── Normativa ──────────────────────────────────────────────────────────
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

  // ── Normativa RGPD ─────────────────────────────────────────────────────────
  /// RGPD Art. 30 — timestamp de creación del perfil.
  final DateTime createdAt;

  /// RGPD Art. 5.1.d — fecha de última modificación; política de caducidad.
  final DateTime updatedAt;

  /// RGPD Art. 5.1.b — si el perfil es visible públicamente en el directorio.
  final bool isPublic;

  /// LOPDGDD Art. 7 — el músico ha verificado tener 14+ años.
  final bool? ageConsent;

  // ── Identificadores de la industria ───────────────────────────────────────
  /// ISO 27729 / SGAE — International Standard Name Identifier del artista.
  final String? isniCode;

  /// CISAC / SGAE — código IPI/CAE del compositor o intérprete.
  final String? ipiCode;

  /// RD 1434/1992 — inscripción en SGAE u otra entidad de gestión colectiva.
  final bool sgaeRegistered;

  // ── Fiscal / laboral ───────────────────────────────────────────────────────
  /// AEAT / Ley 58/2003 — NIF o NIE.
  /// ⚠️ Obligatorio si la app facilita pagos directos (retención IRPF 15%).
  final String? taxId;

  /// LIVA / AEAT — dado de alta en el IAE (epígrafe actividades artísticas).
  final bool vatRegistered;

  /// RD 1434/1992 Art. 3 — nacionalidad para contratos y permisos de trabajo.
  final String? nationality;

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? bio,
    String? location,
    List<String>? skills,
    Map<String, String>? links,
    Object? photoUrl = _unset,
    Map<String, List<String>>? influences,
    bool? availableForHire,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    bool? ageConsent,
    String? isniCode,
    String? ipiCode,
    bool? sgaeRegistered,
    String? taxId,
    bool? vatRegistered,
    String? nationality,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      links: links ?? this.links,
      photoUrl: identical(photoUrl, _unset) ? this.photoUrl : photoUrl as String?,
      influences: influences ?? this.influences,
      availableForHire: availableForHire ?? this.availableForHire,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      ageConsent: ageConsent ?? this.ageConsent,
      isniCode: isniCode ?? this.isniCode,
      ipiCode: ipiCode ?? this.ipiCode,
      sgaeRegistered: sgaeRegistered ?? this.sgaeRegistered,
      taxId: taxId ?? this.taxId,
      vatRegistered: vatRegistered ?? this.vatRegistered,
      nationality: nationality ?? this.nationality,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    bio,
    location,
    skills,
    links,
    photoUrl,
    influences,
    availableForHire,
    createdAt,
    updatedAt,
    isPublic,
    ageConsent,
    isniCode,
    ipiCode,
    sgaeRegistered,
    taxId,
    vatRegistered,
    nationality,
  ];
}
