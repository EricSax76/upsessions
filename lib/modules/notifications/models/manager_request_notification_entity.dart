import 'package:cloud_firestore/cloud_firestore.dart';

import '../../event_manager/models/musician_request_entity.dart';
import 'notification_scenario.dart';

class ManagerRequestNotificationEntity {
  const ManagerRequestNotificationEntity({
    required this.id,
    required this.message,
    required this.status,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String message;
  final RequestStatus status;
  final bool read;
  final DateTime createdAt;

  NotificationScenario get scenario {
    switch (status) {
      case RequestStatus.accepted:
        return NotificationScenario.managerRequestAccepted;
      case RequestStatus.rejected:
        return NotificationScenario.managerRequestRejected;
      case RequestStatus.pending:
        return NotificationScenario.managerRequestPending;
    }
  }

  factory ManagerRequestNotificationEntity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawStatus = (data['status'] ?? 'pending').toString();
    final createdAt = data['createdAt'];

    return ManagerRequestNotificationEntity(
      id: doc.id,
      message: (data['message'] ?? '').toString(),
      status: RequestStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => RequestStatus.pending,
      ),
      read: data['readByManager'] == true,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
