import 'package:equatable/equatable.dart';

enum RequestStatus { pending, accepted, rejected }

class MusicianRequestEntity extends Equatable {
  const MusicianRequestEntity({
    required this.id,
    required this.managerId,
    required this.musicianId,
    this.eventId,
    this.jamSessionId,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String managerId;
  final String musicianId;
  final String? eventId;
  final String? jamSessionId;
  final RequestStatus status;
  final String message;
  final DateTime createdAt;

  MusicianRequestEntity copyWith({
    String? id,
    String? managerId,
    String? musicianId,
    String? eventId,
    String? jamSessionId,
    RequestStatus? status,
    String? message,
    DateTime? createdAt,
  }) {
    return MusicianRequestEntity(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      musicianId: musicianId ?? this.musicianId,
      eventId: eventId ?? this.eventId,
      jamSessionId: jamSessionId ?? this.jamSessionId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        managerId,
        musicianId,
        eventId,
        jamSessionId,
        status,
        message,
        createdAt,
      ];
}
