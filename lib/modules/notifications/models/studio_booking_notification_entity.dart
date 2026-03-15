import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_scenario.dart';

class StudioBookingNotificationEntity {
  const StudioBookingNotificationEntity({
    required this.id,
    required this.bookingId,
    required this.studioId,
    required this.roomName,
    required this.startTime,
    required this.totalPrice,
    required this.status,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String studioId;
  final String roomName;
  final DateTime? startTime;
  final double totalPrice;
  final String status;
  final bool read;
  final DateTime? createdAt;

  NotificationScenario get scenario {
    switch (status) {
      case 'confirmed':
        return NotificationScenario.studioBookingConfirmed;
      case 'cancelled':
      case 'refunded':
        return NotificationScenario.studioBookingCancelled;
      default:
        return NotificationScenario.studioBookingPending;
    }
  }

  factory StudioBookingNotificationEntity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final startTime = data['startTime'];
    final createdAt = data['createdAt'];
    final totalPrice = data['totalPrice'];

    return StudioBookingNotificationEntity(
      id: doc.id,
      bookingId: (data['id'] ?? doc.id).toString(),
      studioId: (data['studioId'] ?? '').toString(),
      roomName: (data['roomName'] ?? '').toString(),
      startTime: startTime is Timestamp ? startTime.toDate() : null,
      totalPrice: totalPrice is num ? totalPrice.toDouble() : 0,
      status: (data['status'] ?? 'pending').toString(),
      read: data['readByOwner'] == true,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
