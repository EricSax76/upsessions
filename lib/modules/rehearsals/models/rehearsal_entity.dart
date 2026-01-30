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
  });

  final String id;
  final String groupId;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String notes;
  final String createdBy;

  @override
  List<Object?> get props =>
      [id, groupId, startsAt, endsAt, location, notes, createdBy];
}

