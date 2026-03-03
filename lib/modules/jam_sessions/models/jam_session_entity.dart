import 'package:equatable/equatable.dart';

/// Entidad de sesión de jam.
///
/// Campos normativos añadidos:
/// - [province]       → Geolocalización — complementa [city]
/// - [maxAttendees]   → Reglamento espectáculos — aforo máximo permitido
/// - [isPublic]       → RGPD Art. 5.1.b — sesión pública vs privada
/// - [venueId]        → Trazabilidad — dónde se celebra (referencia a StudioEntity)
/// - [entryFee]       → LIVA / transparencia — cobro de entrada (incluye IVA)
/// - [ageRestriction] → LOPDGDD / ocio nocturno — edad mínima
/// - [createdAt]      → RGPD Art. 30 — trazabilidad
/// - [updatedAt]      → RGPD Art. 5.1.d — exactitud del dato
/// - [attendees]      → Responsabilidad civil — lista de IDs de participantes
class JamSessionEntity extends Equatable {
  const JamSessionEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.city,
    this.coverImageUrl,
    this.instrumentRequirements = const [],
    this.isCanceled = false,
    // ── Normativa ────────────────────────────────────────────────────────────
    this.province,
    this.maxAttendees,
    this.isPublic = true,
    this.venueId,
    this.entryFee,
    this.ageRestriction,
    this.createdAt,
    this.updatedAt,
    this.attendees = const [],
  });

  const JamSessionEntity.empty()
      : id = '',
        ownerId = '',
        title = '',
        description = '',
        date = null,
        time = '',
        location = '',
        city = '',
        coverImageUrl = null,
        instrumentRequirements = const [],
        isCanceled = false,
        // Normativa
        province = null,
        maxAttendees = null,
        isPublic = true,
        venueId = null,
        entryFee = null,
        ageRestriction = null,
        createdAt = null,
        updatedAt = null,
        attendees = const [];

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final DateTime? date;
  final String time;
  final String location;
  final String city;
  final String? coverImageUrl;
  final List<String> instrumentRequirements;
  final bool isCanceled;

  // ── Normativa ─────────────────────────────────────────────────────────────

  /// Geolocalización — provincia; complementa a [city] para filtrado regional.
  final String? province;

  /// Reglamento espectáculos / seguridad — aforo máximo permitido.
  /// Obligatorio si se celebra en un local con licencia de actividad.
  final int? maxAttendees;

  /// RGPD Art. 5.1.b / Práctico — distingue una jam pública (visible en el directorio)
  /// de una jam privada (solo por invitación directa).
  final bool isPublic;

  /// Trazabilidad — ID del estudio o local (si aplica) donde se celebra.
  final String? venueId;

  /// LIVA / transparencia — importe de la entrada. Si es gratuito, será `null` o `0`.
  /// Tributa IVA (generalmente 21%, a veces 10% si es espectáculo cultural).
  final double? entryFee;

  /// LOPDGDD / Reglamento espectáculos — edad mínima para asistir
  /// (ej. 18 años si es en un local nocturno con barra).
  final int? ageRestriction;

  /// RGPD Art. 30 / contabilidad — cuándo se creó el evento.
  final DateTime? createdAt;

  /// RGPD Art. 5.1.d — última modificación; exactitud del registro.
  final DateTime? updatedAt;

  /// Responsabilidad civil / aforo — lista de IDs de usuarios confirmados.
  /// Útil en caso de evacuación o seguro del local.
  final List<String> attendees;

  bool get isActive =>
      !isCanceled && (date == null || date!.isAfter(DateTime.now()));

  JamSessionEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? city,
    String? coverImageUrl,
    List<String>? instrumentRequirements,
    bool? isCanceled,
    String? province,
    int? maxAttendees,
    bool? isPublic,
    String? venueId,
    double? entryFee,
    int? ageRestriction,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attendees,
  }) {
    return JamSessionEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      city: city ?? this.city,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      instrumentRequirements:
          instrumentRequirements ?? this.instrumentRequirements,
      isCanceled: isCanceled ?? this.isCanceled,
      province: province ?? this.province,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isPublic: isPublic ?? this.isPublic,
      venueId: venueId ?? this.venueId,
      entryFee: entryFee ?? this.entryFee,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attendees: attendees ?? this.attendees,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        date,
        time,
        location,
        city,
        coverImageUrl,
        instrumentRequirements,
        isCanceled,
        province,
        maxAttendees,
        isPublic,
        venueId,
        entryFee,
        ageRestriction,
        createdAt,
        updatedAt,
        attendees,
      ];
}
