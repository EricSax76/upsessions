import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_scenario.dart';

class VenueActivityNotificationEntity {
  const VenueActivityNotificationEntity({
    required this.id,
    required this.sessionId,
    required this.venueId,
    required this.title,
    required this.date,
    required this.city,
    required this.isPublic,
    required this.isCanceled,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String venueId;
  final String title;
  final DateTime? date;
  final String city;
  final bool isPublic;
  final bool isCanceled;
  final DateTime? createdAt;

  NotificationScenario get scenario {
    if (isCanceled) {
      return NotificationScenario.venueJamSessionCancelled;
    }
    if (!isPublic) {
      return NotificationScenario.venueJamSessionPrivate;
    }
    return NotificationScenario.venueJamSessionScheduled;
  }

  factory VenueActivityNotificationEntity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final date = data['date'];
    final createdAt = data['createdAt'];

    return VenueActivityNotificationEntity(
      id: doc.id,
      sessionId: doc.id,
      venueId: (data['venueId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      date: date is Timestamp ? date.toDate() : null,
      city: (data['city'] ?? '').toString(),
      isPublic: data['isPublic'] == true,
      isCanceled: data['isCanceled'] == true,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
