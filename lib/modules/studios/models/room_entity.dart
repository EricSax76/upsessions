import 'package:equatable/equatable.dart';

/// Entidad de sala de estudio / ensayo.
///
/// Campos normativos añadidos:
/// - [maxDecibels]        → Ordenanzas municipales de ruido — nivel sonoro máximo permitido
/// - [isAccessible]       → RD 1/2013 (LIONDAU) — accesibilidad para movilidad reducida
/// - [minBookingHours]    → Contractual / práctica habitual — mínimo de horas por reserva
/// - [cancellationPolicy] → Directiva 2011/83/UE — política de cancelación y devolución
/// - [isActive]           → Operacional — sala disponible o temporalmente fuera de servicio
/// - [ageRestriction]     → LOPDGDD Art. 7 / autonomía regional — restricción de edad
/// - [updatedAt]          → RGPD Art. 5.1.d — exactitud del dato
class RoomEntity extends Equatable {
  const RoomEntity({
    required this.id,
    required this.studioId,
    required this.name,
    required this.capacity,
    required this.size,
    required this.equipment,
    required this.amenities,
    required this.pricePerHour,
    required this.photos,
    // ── Normativa ────────────────────────────────────────────────────────────
    this.maxDecibels,
    this.isAccessible = false,
    this.minBookingHours = 1,
    this.cancellationPolicy,
    this.isActive = true,
    this.ageRestriction,
    this.updatedAt,
  });

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String studioId;
  final String name;
  final int capacity;
  final String size;
  final List<String> equipment;
  final List<String> amenities;
  final double pricePerHour;
  final List<String> photos;

  // ── Normativa ─────────────────────────────────────────────────────────────

  /// Ordenanzas municipales de ruido — decibelios máximos permitidos en la sala.
  final double? maxDecibels;

  /// RD 1/2013 (LIONDAU) — la sala cumple requisitos de accesibilidad
  /// para personas con movilidad reducida.
  final bool isAccessible;

  /// Contractual — número mínimo de horas por reserva; reduce disputas.
  final int minBookingHours;

  /// Directiva 2011/83/UE (derechos del consumidor) — política de
  /// cancelación y devolución; obligatoria cuando hay pagos online.
  final String? cancellationPolicy;

  /// Operacional — sala disponible (`true`) o temporalmente cerrada.
  /// Permite ocultar salas sin borrarlas de Firestore.
  final bool isActive;

  /// LOPDGDD Art. 7 / normativa autonómica — edad mínima para usar la sala
  /// (ej. 18 en locales de ocio nocturno con licencia de bar).
  final int? ageRestriction;

  /// RGPD Art. 5.1.d — última modificación del registro; política de caducidad.
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        studioId,
        name,
        capacity,
        size,
        equipment,
        amenities,
        pricePerHour,
        photos,
        maxDecibels,
        isAccessible,
        minBookingHours,
        cancellationPolicy,
        isActive,
        ageRestriction,
        updatedAt,
      ];

  RoomEntity copyWith({
    String? id,
    String? studioId,
    String? name,
    int? capacity,
    String? size,
    List<String>? equipment,
    List<String>? amenities,
    double? pricePerHour,
    List<String>? photos,
    double? maxDecibels,
    bool? isAccessible,
    int? minBookingHours,
    String? cancellationPolicy,
    bool? isActive,
    int? ageRestriction,
    DateTime? updatedAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      size: size ?? this.size,
      equipment: equipment ?? this.equipment,
      amenities: amenities ?? this.amenities,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      photos: photos ?? this.photos,
      maxDecibels: maxDecibels ?? this.maxDecibels,
      isAccessible: isAccessible ?? this.isAccessible,
      minBookingHours: minBookingHours ?? this.minBookingHours,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      isActive: isActive ?? this.isActive,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
