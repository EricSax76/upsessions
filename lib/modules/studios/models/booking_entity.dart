import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled }

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
    this.rehearsalId,
    this.groupId,
  });

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
      ];

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
    );
  }
}

