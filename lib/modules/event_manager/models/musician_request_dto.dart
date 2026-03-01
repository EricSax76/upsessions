import 'package:cloud_firestore/cloud_firestore.dart';
import 'musician_request_entity.dart';

class MusicianRequestDto {
  const MusicianRequestDto({
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
  final String status;
  final String message;
  final Timestamp createdAt;

  factory MusicianRequestDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return MusicianRequestDto(
      id: snapshot.id,
      managerId: data['managerId'] as String? ?? '',
      musicianId: data['musicianId'] as String? ?? '',
      eventId: data['eventId'] as String?,
      jamSessionId: data['jamSessionId'] as String?,
      status: data['status'] as String? ?? 'pending',
      message: data['message'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory MusicianRequestDto.fromEntity(MusicianRequestEntity entity) {
    return MusicianRequestDto(
      id: entity.id,
      managerId: entity.managerId,
      musicianId: entity.musicianId,
      eventId: entity.eventId,
      jamSessionId: entity.jamSessionId,
      status: entity.status.name,
      message: entity.message,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  MusicianRequestEntity toEntity() {
    return MusicianRequestEntity(
      id: id,
      managerId: managerId,
      musicianId: musicianId,
      eventId: eventId,
      jamSessionId: jamSessionId,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => RequestStatus.pending,
      ),
      message: message,
      createdAt: createdAt.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'musicianId': musicianId,
      if (eventId != null) 'eventId': eventId,
      if (jamSessionId != null) 'jamSessionId': jamSessionId,
      'status': status,
      'message': message,
      'createdAt': createdAt,
    };
  }
}
