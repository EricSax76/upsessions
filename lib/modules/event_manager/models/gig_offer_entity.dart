import 'package:equatable/equatable.dart';

/// Estado de la oferta de trabajo.
enum GigOfferStatus { open, closed, cancelled, completed }

/// Tipo de relación contractual con el artista.
///
/// ⚠️ IMPORTANTE (RD 1434/1992): los artistas tienen una relación laboral
/// especial. La confusión entre `cachet_autonomo` y `contrato_laboral_especial`
/// puede derivar en sanciones laborales para el contratante.
enum GigContractType {
  /// Artista autónomo que factura con retención IRPF (normalmente 15 %).
  cachetAutonomo,

  /// Relación laboral especial de artistas (RD 1434/1992, arts. 1–3).
  contratoLaboralEspecial,

  /// Colaboración puntual sin relación laboral ni mercantil formal.
  colaboracion,
}

/// Entidad de oferta de trabajo / bolo publicada por un manager.
///
/// Campos normativos añadidos:
/// - [contractType]            → RD 1434/1992 / ET — tipo de relación laboral
/// - [irpfRetention]           → AEAT / IRPF — % retención (normalmente 15 %)
/// - [province]                → Práctico / geolocalización — filtrado y matching
/// - [isPublic]                → Práctico — oferta pública vs. invitación directa
/// - [expiresAt]               → RGPD Art. 5.1.e — evita ofertas "zombies"
/// - [updatedAt]               → RGPD Art. 5.1.d — trazabilidad de modificaciones
/// - [selectedMusicianId]      → Contractual — músico contratado; base del contrato
/// - [requiresContract]        → RD 1434/1992 — si se exige contrato artístico formal
/// - [minimumExperienceYears]  → Práctico — filtro de candidatos
/// - [isRemote]                → Post-COVID — sesiones de grabación remotas
class GigOfferEntity extends Equatable {
  const GigOfferEntity({
    required this.id,
    required this.managerId,
    required this.title,
    required this.description,
    required this.instrumentRequirements,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.applicants,
    required this.createdAt,
    this.budget,
    // ── Normativa ────────────────────────────────────────────────────────────
    this.contractType = GigContractType.cachetAutonomo,
    this.irpfRetention,
    this.province,
    this.isPublic = true,
    this.expiresAt,
    this.updatedAt,
    this.selectedMusicianId,
    this.requiresContract = false,
    this.minimumExperienceYears,
    this.isRemote = false,
  });

  const GigOfferEntity.empty()
      : id = '',
        managerId = '',
        title = '',
        description = '',
        instrumentRequirements = const [],
        date = null,
        time = '',
        location = '',
        budget = null,
        status = GigOfferStatus.open,
        applicants = const [],
        createdAt = null,
        // Normativa — valores por defecto seguros
        contractType = GigContractType.cachetAutonomo,
        irpfRetention = null,
        province = null,
        isPublic = true,
        expiresAt = null,
        updatedAt = null,
        selectedMusicianId = null,
        requiresContract = false,
        minimumExperienceYears = null,
        isRemote = false;

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String managerId;
  final String title;
  final String description;
  final List<String> instrumentRequirements;
  final DateTime? date;
  final String time;
  final String location;
  final String? budget;
  final GigOfferStatus status;
  final List<String> applicants;
  final DateTime? createdAt;

  // ── Normativa ─────────────────────────────────────────────────────────────

  /// RD 1434/1992 / ET — tipo de relación contractual con el artista.
  /// ⚠️ CRÍTICO: confundirlo puede derivar en sanciones laborales.
  final GigContractType contractType;

  /// AEAT / IRPF — porcentaje de retención a aplicar en la factura.
  /// Normalmente 15 % para artistas autónomos (art. 101 LIRPF).
  final double? irpfRetention;

  /// Provincia del evento; mejora el filtrado geográfico.
  final String? province;

  /// Oferta visible en el directorio público o solo por invitación.
  final bool isPublic;

  /// RGPD Art. 5.1.e — fecha límite de candidatura; evita ofertas "zombies".
  final DateTime? expiresAt;

  /// RGPD Art. 5.1.d — última modificación; trazabilidad de cambios.
  final DateTime? updatedAt;

  /// Contractual — ID del músico finalmente seleccionado; base para el contrato.
  final String? selectedMusicianId;

  /// RD 1434/1992 — indica si la oferta exige contrato artístico formal.
  final bool requiresContract;

  /// Años mínimos de experiencia requeridos; filtra candidatos no aptos.
  final int? minimumExperienceYears;

  /// Si la sesión / bolo admite formato remoto (post-COVID).
  final bool isRemote;

  /// La oferta está vigente si no ha expirado y el estado es abierto.
  bool get isActive =>
      status == GigOfferStatus.open &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  GigOfferEntity copyWith({
    String? id,
    String? managerId,
    String? title,
    String? description,
    List<String>? instrumentRequirements,
    DateTime? date,
    String? time,
    String? location,
    String? budget,
    GigOfferStatus? status,
    List<String>? applicants,
    DateTime? createdAt,
    GigContractType? contractType,
    double? irpfRetention,
    String? province,
    bool? isPublic,
    DateTime? expiresAt,
    DateTime? updatedAt,
    String? selectedMusicianId,
    bool? requiresContract,
    int? minimumExperienceYears,
    bool? isRemote,
  }) {
    return GigOfferEntity(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      title: title ?? this.title,
      description: description ?? this.description,
      instrumentRequirements:
          instrumentRequirements ?? this.instrumentRequirements,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
      createdAt: createdAt ?? this.createdAt,
      contractType: contractType ?? this.contractType,
      irpfRetention: irpfRetention ?? this.irpfRetention,
      province: province ?? this.province,
      isPublic: isPublic ?? this.isPublic,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedMusicianId: selectedMusicianId ?? this.selectedMusicianId,
      requiresContract: requiresContract ?? this.requiresContract,
      minimumExperienceYears:
          minimumExperienceYears ?? this.minimumExperienceYears,
      isRemote: isRemote ?? this.isRemote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        managerId,
        title,
        description,
        instrumentRequirements,
        date,
        time,
        location,
        budget,
        status,
        applicants,
        createdAt,
        contractType,
        irpfRetention,
        province,
        isPublic,
        expiresAt,
        updatedAt,
        selectedMusicianId,
        requiresContract,
        minimumExperienceYears,
        isRemote,
      ];
}
