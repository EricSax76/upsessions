import 'package:equatable/equatable.dart';

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
  });

  final String id;
  final String groupId;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String notes;
  final String createdBy;
  final String? bookingId;

  @override
  List<Object?> get props =>
      [id, groupId, startsAt, endsAt, location, notes, createdBy, bookingId];

  RehearsalEntity copyWith({
    String? id,
    String? groupId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? notes,
    String? createdBy,
    String? bookingId,
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
    );
  }
}
