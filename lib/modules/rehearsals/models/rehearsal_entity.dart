import 'package:equatable/equatable.dart';

/// Entidad de ensayo de grupo.
///
/// Campos normativos añadidos:
/// - [title]              → UX / práctico — nombre descriptivo del ensayo
/// - [setlistId]          → Práctico artístico — referencia al setlist trabajado
/// - [attendees]          → Responsabilidad / contingencia interne — miembros presentes
/// - [isConfirmed]        → Contractual — distingue ensayos propuestos de los confirmados
/// - [canceledAt]         → RGPD Art. 5 / contractual — timestamp de cancelación
/// - [cancellationReason] → Contractual — motivo, relevante si hay reserva externa vinculada
/// - [updatedAt]          → RGPD Art. 5.1.d — exactitud del dato
class RehearsalEntity extends Equatable {
  const RehearsalEntity({
    required this.id,
    required this.groupId,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.notes,
    required this.createdBy,
    this.bookingId,
    // ── Normativa ────────────────────────────────────────────────────────────
    this.title,
    this.setlistId,
    this.attendees = const [],
    this.isConfirmed = false,
    this.canceledAt,
    this.cancellationReason,
    this.updatedAt,
  });

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String groupId;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String notes;
  final String createdBy;
  final String? bookingId;

  // ── Normativa ─────────────────────────────────────────────────────────────

  /// UX / práctico — Nombre descriptivo del ensayo (ej. "Ensayo general gira").
  final String? title;

  /// Práctico / artístico — ID del repertorio o setlist trabajado en la sesión.
  final String? setlistId;

  /// Responsabilidad interna / contabilidad — lista de IDs de miembros presentes.
  final List<String> attendees;

  /// Contractual — indica si el ensayo es un borrador/propuesta o está confirmado por el grupo.
  final bool isConfirmed;

  /// Contractual / trazabilidad — fecha en la que se canceló (si aplica).
  /// Relevante si el grupo tiene que asumir costes de un booking vinculado.
  final DateTime? canceledAt;

  /// Contractual — justificación de la cancelación del ensayo.
  final String? cancellationReason;

  /// RGPD Art. 5.1.d — última modificación; exactitud del registro.
  final DateTime? updatedAt;

  bool get isCanceled => canceledAt != null;
  bool get isActive => !isCanceled && (endsAt == null || endsAt!.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [
        id,
        groupId,
        startsAt,
        endsAt,
        location,
        notes,
        createdBy,
        bookingId,
        title,
        setlistId,
        attendees,
        isConfirmed,
        canceledAt,
        cancellationReason,
        updatedAt,
      ];

  RehearsalEntity copyWith({
    String? id,
    String? groupId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? notes,
    String? createdBy,
    String? bookingId,
    String? title,
    String? setlistId,
    List<String>? attendees,
    bool? isConfirmed,
    DateTime? canceledAt,
    String? cancellationReason,
    DateTime? updatedAt,
  }) {
    return RehearsalEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      bookingId: bookingId ?? this.bookingId,
      title: title ?? this.title,
      setlistId: setlistId ?? this.setlistId,
      attendees: attendees ?? this.attendees,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      canceledAt: canceledAt ?? this.canceledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
