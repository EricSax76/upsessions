import 'package:cloud_firestore/cloud_firestore.dart';
import 'gig_offer_entity.dart';

/// DTO para serialización/deserialización de [GigOfferEntity] en Firestore.
///
/// Campos normativos añadidos (espejo de [GigOfferEntity]):
/// [contractType], [irpfRetention], [province], [isPublic], [expiresAt],
/// [updatedAt], [selectedMusicianId], [requiresContract],
/// [minimumExperienceYears], [isRemote].
class GigOfferDto {
  const GigOfferDto({
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
    // ── Normativa ───────────────────────────────────────────────────────────
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

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String managerId;
  final String title;
  final String description;
  final List<String> instrumentRequirements;
  final Timestamp? date;
  final String time;
  final String location;
  final String? budget;
  final String status;
  final List<String> applicants;
  final Timestamp? createdAt;

  // ── Normativa ─────────────────────────────────────────────────────────────
  final GigContractType contractType;
  final double? irpfRetention;
  final String? province;
  final bool isPublic;
  final Timestamp? expiresAt;
  final Timestamp? updatedAt;
  final String? selectedMusicianId;
  final bool requiresContract;
  final int? minimumExperienceYears;
  final bool isRemote;

  // ── Deserialización ───────────────────────────────────────────────────────
  factory GigOfferDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return GigOfferDto(
      id: snapshot.id,
      managerId: data['managerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      instrumentRequirements: List<String>.from(
        data['instrumentRequirements'] ?? [],
      ),
      date: data['date'] as Timestamp?,
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      budget: data['budget'] as String?,
      status: data['status'] as String? ?? GigOfferStatus.open.name,
      applicants: List<String>.from(data['applicants'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
      // Normativa
      contractType: _contractTypeFromString(data['contractType'] as String?),
      irpfRetention: (data['irpfRetention'] as num?)?.toDouble(),
      province: data['province'] as String?,
      isPublic: (data['isPublic'] as bool?) ?? true,
      expiresAt: data['expiresAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      selectedMusicianId: data['selectedMusicianId'] as String?,
      requiresContract: (data['requiresContract'] as bool?) ?? false,
      minimumExperienceYears:
          (data['minimumExperienceYears'] as num?)?.toInt(),
      isRemote: (data['isRemote'] as bool?) ?? false,
    );
  }

  factory GigOfferDto.fromEntity(GigOfferEntity entity) {
    return GigOfferDto(
      id: entity.id,
      managerId: entity.managerId,
      title: entity.title,
      description: entity.description,
      instrumentRequirements: entity.instrumentRequirements,
      date: entity.date != null ? Timestamp.fromDate(entity.date!) : null,
      time: entity.time,
      location: entity.location,
      budget: entity.budget,
      status: entity.status.name,
      applicants: entity.applicants,
      createdAt:
          entity.createdAt != null ? Timestamp.fromDate(entity.createdAt!) : null,
      // Normativa
      contractType: entity.contractType,
      irpfRetention: entity.irpfRetention,
      province: entity.province,
      isPublic: entity.isPublic,
      expiresAt:
          entity.expiresAt != null ? Timestamp.fromDate(entity.expiresAt!) : null,
      updatedAt:
          entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
      selectedMusicianId: entity.selectedMusicianId,
      requiresContract: entity.requiresContract,
      minimumExperienceYears: entity.minimumExperienceYears,
      isRemote: entity.isRemote,
    );
  }

  // ── Serialización ─────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'title': title,
      'description': description,
      'instrumentRequirements': instrumentRequirements,
      if (date != null) 'date': date,
      'time': time,
      'location': location,
      if (budget != null) 'budget': budget,
      'status': status,
      'applicants': applicants,
      if (createdAt != null) 'createdAt': createdAt,
      // Normativa
      'contractType': contractType.name,
      if (irpfRetention != null) 'irpfRetention': irpfRetention,
      if (province != null) 'province': province,
      'isPublic': isPublic,
      if (expiresAt != null) 'expiresAt': expiresAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (selectedMusicianId != null) 'selectedMusicianId': selectedMusicianId,
      'requiresContract': requiresContract,
      if (minimumExperienceYears != null)
        'minimumExperienceYears': minimumExperienceYears,
      'isRemote': isRemote,
    };
  }

  // ── Conversión a entidad ──────────────────────────────────────────────────
  GigOfferEntity toEntity() {
    return GigOfferEntity(
      id: id,
      managerId: managerId,
      title: title,
      description: description,
      instrumentRequirements: instrumentRequirements,
      date: date?.toDate(),
      time: time,
      location: location,
      budget: budget,
      status: GigOfferStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => GigOfferStatus.open,
      ),
      applicants: applicants,
      createdAt: createdAt?.toDate(),
      contractType: contractType,
      irpfRetention: irpfRetention,
      province: province,
      isPublic: isPublic,
      expiresAt: expiresAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
      selectedMusicianId: selectedMusicianId,
      requiresContract: requiresContract,
      minimumExperienceYears: minimumExperienceYears,
      isRemote: isRemote,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static GigContractType _contractTypeFromString(String? raw) {
    if (raw == null) return GigContractType.cachetAutonomo;
    return GigContractType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GigContractType.cachetAutonomo,
    );
  }
}
