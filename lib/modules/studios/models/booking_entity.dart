import 'package:equatable/equatable.dart';

/// Estado de la reserva.
enum BookingStatus { pending, confirmed, cancelled, refunded }

/// Método de pago.
enum BookingPaymentMethod { card, transfer, cash, bizum }

/// Estado del pago.
enum BookingPaymentStatus { pending, paid, refunded, failed }

/// Entidad de reserva de sala de estudio / ensayo.
///
/// Campos normativos añadidos:
/// - [invoiceId]          → AEAT / Ley 37/1992 LIVA — referencia a la factura emitida
/// - [vatAmount]          → LIVA Art. 75 — desglose del IVA (21 % general); obligatorio en facturas
/// - [paymentMethod]      → PSD2 / transparencia — método de pago utilizado
/// - [paymentStatus]      → PSD2 / contabilidad — estado del cobro
/// - [cancellationReason] → Directiva 2011/83/UE — motivo de cancelación para devoluciones
/// - [refundAmount]       → Directiva consumidor — importe devuelto en cancelación
/// - [confirmedAt]        → Contractual — timestamp del contrato perfeccionado
/// - [createdAt]          → RGPD Art. 30 / contabilidad — trazabilidad y libros contables
/// - [updatedAt]          → RGPD Art. 5.1.d — exactitud del dato
/// - [attendees]          → Responsabilidad civil / aforo — lista de músicos presentes
class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.studioId,
    required this.studioName,
    required this.ownerId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.rehearsalId,
    this.groupId,
    // ── Normativa ────────────────────────────────────────────────────────────
    this.invoiceId,
    this.vatAmount,
    this.paymentMethod,
    this.paymentStatus = BookingPaymentStatus.pending,
    this.cancellationReason,
    this.refundAmount,
    this.confirmedAt,
    this.updatedAt,
    this.attendees = const [],
  });

  // ── Campos existentes ─────────────────────────────────────────────────────
  final String id;
  final String roomId;
  final String roomName;
  final String studioId;
  final String studioName;
  final String ownerId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final double totalPrice;
  final String? rehearsalId;
  final String? groupId;

  // ── Normativa AEAT / LIVA ─────────────────────────────────────────────────
  /// AEAT / Ley 37/1992 — referencia a la factura emitida.
  /// ⚠️ Sin este campo la app no puede generar facturas legalmente válidas.
  final String? invoiceId;

  /// LIVA Art. 75 — importe de IVA desglosado (21 % general).
  /// ⚠️ Obligatorio en toda factura según RD 1619/2012 Art. 6.
  final double? vatAmount;

  // ── Normativa PSD2 / pagos ────────────────────────────────────────────────
  /// PSD2 / transparencia — método de pago utilizado.
  final BookingPaymentMethod? paymentMethod;

  /// PSD2 / contabilidad — estado actual del cobro.
  final BookingPaymentStatus paymentStatus;

  // ── Normativa directiva consumidor ────────────────────────────────────────
  /// Directiva 2011/83/UE — motivo de cancelación; necesario para devoluciones.
  final String? cancellationReason;

  /// Directiva consumidor — importe devuelto en caso de cancelación.
  final double? refundAmount;

  // ── Trazabilidad / RGPD ───────────────────────────────────────────────────
  /// Contractual — timestamp de confirmación; prueba del contrato perfeccionado.
  final DateTime? confirmedAt;

  /// RGPD Art. 30 / contabilidad — timestamp de creación; libros contables.
  final DateTime createdAt;

  /// RGPD Art. 5.1.d — última modificación; exactitud del dato.
  final DateTime? updatedAt;

  // ── Responsabilidad civil / aforo ─────────────────────────────────────────
  /// Lista de `userId`s de músicos presentes; útil para aforo y seguros.
  final List<String> attendees;

  /// Importe neto sin IVA (totalPrice − vatAmount).
  double get netAmount => totalPrice - (vatAmount ?? 0.0);

  /// La reserva está activa si no ha sido cancelada ni reembolsada.
  bool get isActive =>
      status != BookingStatus.cancelled &&
      status != BookingStatus.refunded;

  BookingEntity copyWith({
    String? id,
    String? roomId,
    String? roomName,
    String? studioId,
    String? studioName,
    String? ownerId,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    double? totalPrice,
    String? rehearsalId,
    String? groupId,
    String? invoiceId,
    double? vatAmount,
    BookingPaymentMethod? paymentMethod,
    BookingPaymentStatus? paymentStatus,
    String? cancellationReason,
    double? refundAmount,
    DateTime? confirmedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attendees,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      studioId: studioId ?? this.studioId,
      studioName: studioName ?? this.studioName,
      ownerId: ownerId ?? this.ownerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      rehearsalId: rehearsalId ?? this.rehearsalId,
      groupId: groupId ?? this.groupId,
      invoiceId: invoiceId ?? this.invoiceId,
      vatAmount: vatAmount ?? this.vatAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundAmount: refundAmount ?? this.refundAmount,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attendees: attendees ?? this.attendees,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        roomName,
        studioId,
        studioName,
        ownerId,
        startTime,
        endTime,
        status,
        totalPrice,
        rehearsalId,
        groupId,
        invoiceId,
        vatAmount,
        paymentMethod,
        paymentStatus,
        cancellationReason,
        refundAmount,
        confirmedAt,
        createdAt,
        updatedAt,
        attendees,
      ];
}
