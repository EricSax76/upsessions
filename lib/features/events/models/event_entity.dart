import 'package:equatable/equatable.dart';

import 'event_enums.dart';

class EventEntity extends Equatable {
  const EventEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.city,
    required this.venue,
    required this.start,
    required this.end,
    required this.description,
    required this.organizer,
    required this.contactEmail,
    required this.contactPhone,
    required this.lineup,
    required this.tags,
    required this.ticketInfo,
    required this.capacity,
    required this.resources,
    required this.isPublic,
    required this.isFree,
    required this.updatedAt,
    required this.status,
    this.notes,
    this.bannerImageUrl,
    this.province,
    this.postalCode,
    this.eventLicenseNumber,
    this.ticketPrice,
    this.vatRate,
    this.ageRestriction,
    this.accessibilityInfo,
    this.cancellationPolicy,
    this.publishedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String city;
  final String venue;
  final DateTime start;
  final DateTime end;
  final String description;
  final String organizer;
  final String contactEmail;
  final String contactPhone;
  final List<String> lineup;
  final List<String> tags;
  final String ticketInfo;
  final int capacity;
  final List<String> resources;
  final String? notes;
  final String? bannerImageUrl;

  /// Geolocalización — para filtrado y cumplimiento normativa CCAA.
  final String? province;

  /// Fiscal / logística — completar dirección del venue.
  final String? postalCode;

  /// Ley 17/1997 / CCAA — número de autorización/licencia del espectáculo público.
  final String? eventLicenseNumber;

  /// LIVA / transparencia — precio base de la entrada; necesario para desglose IVA.
  final double? ticketPrice;

  /// LIVA Art. 91 — tipo de IVA aplicable (10 % espectáculos culturales en España).
  final double? vatRate;

  /// RGPD Art. 5.1.b — evento público vs. privado.
  final bool isPublic;

  /// Ley 1/1982 / normativa CCAA — restricción de edad (menores en conciertos).
  final int? ageRestriction;

  /// RD 1/2013 (LIONDAU) — información de acceso para personas con discapacidad.
  final String? accessibilityInfo;

  /// Transparencia — evento gratuito; afecta declaración fiscal.
  final bool isFree;

  /// Directiva 2011/83/UE — política de devolución de entradas.
  final String? cancellationPolicy;

  /// Trazabilidad — fecha de publicación del evento.
  final DateTime? publishedAt;

  /// RGPD Art. 5.1.d — exactitud del dato.
  final DateTime updatedAt;

  /// Operacional — draft, published, cancelled, completed.
  final EventStatus status;

  EventEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? city,
    String? venue,
    DateTime? start,
    DateTime? end,
    String? description,
    String? organizer,
    String? contactEmail,
    String? contactPhone,
    List<String>? lineup,
    List<String>? tags,
    String? ticketInfo,
    int? capacity,
    List<String>? resources,
    String? notes,
    String? bannerImageUrl,
    String? province,
    String? postalCode,
    String? eventLicenseNumber,
    double? ticketPrice,
    double? vatRate,
    bool? isPublic,
    int? ageRestriction,
    String? accessibilityInfo,
    bool? isFree,
    String? cancellationPolicy,
    DateTime? publishedAt,
    DateTime? updatedAt,
    EventStatus? status,
  }) {
    return EventEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      city: city ?? this.city,
      venue: venue ?? this.venue,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      lineup: lineup ?? this.lineup,
      tags: tags ?? this.tags,
      ticketInfo: ticketInfo ?? this.ticketInfo,
      capacity: capacity ?? this.capacity,
      resources: resources ?? this.resources,
      notes: notes ?? this.notes,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      eventLicenseNumber: eventLicenseNumber ?? this.eventLicenseNumber,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      vatRate: vatRate ?? this.vatRate,
      isPublic: isPublic ?? this.isPublic,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      accessibilityInfo: accessibilityInfo ?? this.accessibilityInfo,
      isFree: isFree ?? this.isFree,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    title,
    city,
    venue,
    start,
    end,
    description,
    organizer,
    contactEmail,
    contactPhone,
    lineup,
    tags,
    ticketInfo,
    capacity,
    resources,
    notes,
    bannerImageUrl,
    province,
    postalCode,
    eventLicenseNumber,
    ticketPrice,
    vatRate,
    isPublic,
    ageRestriction,
    accessibilityInfo,
    isFree,
    cancellationPolicy,
    publishedAt,
    updatedAt,
    status,
  ];
}
