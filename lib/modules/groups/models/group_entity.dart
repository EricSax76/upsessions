import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    this.description = '',
    this.genres = const [],
    this.city,
    this.province,
    this.members = const [],
    this.memberRoles,
    this.isActive = true,
    this.photoUrl,
    this.links = const {},
    this.foundedAt,
    this.createdAt,
    this.updatedAt,
    this.sgaeGroupCode,
    this.internalRevenueShare,
  });

  final String id;
  final String name;
  final String ownerId;

  /// Descripción del grupo (historial, estilo, trayectoria).
  final String description;

  /// Géneros musicales del grupo.
  final List<String> genres;

  /// Ciudad base del grupo — para filtrado geográfico.
  final String? city;

  /// Provincia — para filtrado y normativa CCAA.
  final String? province;

  /// Lista de `musicianId` de los miembros activos del grupo.
  /// Necesario para contratos grupales y distribución de cachets.
  final List<String> members;

  /// Rol de cada miembro: {'musicianId': 'líder'|'bajista'|...}.
  /// Base contractual para acuerdos internos (Ley Propiedad Intelectual).
  final Map<String, String>? memberRoles;

  /// Grupo activo o disuelto.
  final bool isActive;

  /// URL de la foto del grupo.
  final String? photoUrl;

  /// Redes sociales y enlaces externos. LSSI Art. 10.
  final Map<String, String> links;

  /// Fecha de constitución del grupo. Relevante para contratos artísticos.
  final DateTime? foundedAt;

  /// RGPD Art. 30 — trazabilidad del ciclo de vida del dato.
  final DateTime? createdAt;

  /// RGPD Art. 5.1.d — exactitud; se actualiza en cada modificación.
  final DateTime? updatedAt;

  /// Código del grupo en SGAE u otra entidad de gestión colectiva.
  final String? sgaeGroupCode;

  /// Porcentaje de ingresos por miembro. Base para liquidaciones de cachets.
  /// Formato: {'musicianId': 0.33}.
  final Map<String, double>? internalRevenueShare;

  GroupEntity copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? description,
    List<String>? genres,
    String? city,
    String? province,
    List<String>? members,
    Map<String, String>? memberRoles,
    bool? isActive,
    String? photoUrl,
    Map<String, String>? links,
    DateTime? foundedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sgaeGroupCode,
    Map<String, double>? internalRevenueShare,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      city: city ?? this.city,
      province: province ?? this.province,
      members: members ?? this.members,
      memberRoles: memberRoles ?? this.memberRoles,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      links: links ?? this.links,
      foundedAt: foundedAt ?? this.foundedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sgaeGroupCode: sgaeGroupCode ?? this.sgaeGroupCode,
      internalRevenueShare: internalRevenueShare ?? this.internalRevenueShare,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        description,
        genres,
        city,
        province,
        members,
        memberRoles,
        isActive,
        photoUrl,
        links,
        foundedAt,
        createdAt,
        updatedAt,
        sgaeGroupCode,
        internalRevenueShare,
      ];
}
