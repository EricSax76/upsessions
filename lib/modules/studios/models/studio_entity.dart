import 'package:equatable/equatable.dart';

/// Entidad de estudio de grabación / ensayo.
///
/// Campos normativos añadidos:
/// - [vatNumber]              → LIVA — NIF-IVA para facturas intracomunitarias
/// - [licenseNumber]          → Reglamento espectáculos / Ayuntamiento — licencia municipal
/// - [openingHours]           → LSSI Art. 10 — horario de atención obligatorio en info online
/// - [city]                   → Geolocalización — búsqueda y filtrado
/// - [province]               → Geolocalización — idem
/// - [postalCode]             → Práctico / fiscalidad — facturación y localización exacta
/// - [maxRoomCapacity]        → Reglamento espectáculos — aforo máximo; seguridad
/// - [accessibilityInfo]      → RD 1/2013 (LIONDAU) / Ley 49/2007 — info de accesibilidad
/// - [noiseOrdinanceCompliant]→ Ordenanzas municipales de ruido — cumplimiento acústico
/// - [insuranceExpiry]        → Reglamento espectáculos — caducidad del seguro RC
/// - [updatedAt]              → RGPD Art. 5.1.d — exactitud del dato
/// - [isActive]               → Operacional — estudios activos vs. cerrados temporalmente
class StudioEntity extends Equatable {
  const StudioEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    required this.cif,
    required this.businessName,
    this.logoUrl,
    this.bannerUrl,
    // ── Normativa ────────────────────────────────────────────────────────────
    required this.vatNumber,
    required this.licenseNumber,
    required this.openingHours,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.maxRoomCapacity,
    required this.accessibilityInfo,
    required this.noiseOrdinanceCompliant,
    required this.insuranceExpiry,
    this.updatedAt,
    this.isActive = true,
  });

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String cif;
  final String businessName;
  final String? logoUrl;
  final String? bannerUrl;

  // ── Normativa fiscal ──────────────────────────────────────────────────────
  /// LIVA — NIF-IVA del estudio para facturas intracomunitarias dentro de la UE.
  final String vatNumber;

  // ── Normativa administrativa / seguridad ──────────────────────────────────
  /// Reglamento espectáculos / Ayuntamiento — número de licencia municipal
  /// de actividad o de aforo. Exigible para actuaciones en vivo.
  final String licenseNumber;

  /// Reglamento espectáculos — aforo máximo total de las instalaciones;
  /// requerimiento de seguridad y condición de la licencia.
  final int maxRoomCapacity;

  /// Reglamento espectáculos — fecha de caducidad del seguro de
  /// responsabilidad civil; obligatorio para operar como local público.
  final DateTime insuranceExpiry;

  /// Ordenanzas municipales de ruido — el estudio cumple la normativa acústica
  /// local; relevante para la obtención y renovación de permisos.
  final bool noiseOrdinanceCompliant;

  // ── Normativa LSSI / geolocalización ─────────────────────────────────────
  /// LSSI Art. 10 — horario de atención al público; obligatorio en la
  /// información comercial online. Clave: "lun" → "09:00–18:00".
  final Map<String, String> openingHours;

  /// Ciudad del estudio; necesaria para búsqueda y filtrado.
  final String city;

  /// Provincia del estudio; complementa [city] para filtros geográficos.
  final String province;

  /// Código postal; necesario para facturación y localización exacta.
  final String postalCode;

  // ── Normativa accesibilidad ───────────────────────────────────────────────
  /// RD 1/2013 (LIONDAU) / Ley 49/2007 — información de accesibilidad para
  /// personas con discapacidad; obligatorio en servicios abiertos al público.
  final String accessibilityInfo;

  // ── RGPD / operacional ────────────────────────────────────────────────────
  /// RGPD Art. 5.1.d — última modificación del registro; política de caducidad.
  final DateTime? updatedAt;

  /// Operacional — distingue estudios activos de temporalmente cerrados
  /// sin necesidad de borrar el documento de Firestore.
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        address,
        contactEmail,
        contactPhone,
        cif,
        businessName,
        logoUrl,
        bannerUrl,
        vatNumber,
        licenseNumber,
        openingHours,
        city,
        province,
        postalCode,
        maxRoomCapacity,
        accessibilityInfo,
        noiseOrdinanceCompliant,
        insuranceExpiry,
        updatedAt,
        isActive,
      ];

  StudioEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? cif,
    String? businessName,
    String? logoUrl,
    String? bannerUrl,
    String? vatNumber,
    String? licenseNumber,
    Map<String, String>? openingHours,
    String? city,
    String? province,
    String? postalCode,
    int? maxRoomCapacity,
    String? accessibilityInfo,
    bool? noiseOrdinanceCompliant,
    DateTime? insuranceExpiry,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return StudioEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      cif: cif ?? this.cif,
      businessName: businessName ?? this.businessName,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      vatNumber: vatNumber ?? this.vatNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      openingHours: openingHours ?? this.openingHours,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      maxRoomCapacity: maxRoomCapacity ?? this.maxRoomCapacity,
      accessibilityInfo: accessibilityInfo ?? this.accessibilityInfo,
      noiseOrdinanceCompliant:
          noiseOrdinanceCompliant ?? this.noiseOrdinanceCompliant,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
