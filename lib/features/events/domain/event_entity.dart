import 'package:equatable/equatable.dart';

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
    this.notes,
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
  ];
}
