import 'package:cloud_firestore/cloud_firestore.dart';

class InviteNotificationEntity {
  const InviteNotificationEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviteId,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    required this.read,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String inviteId;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final bool read;

  factory InviteNotificationEntity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    return InviteNotificationEntity(
      id: doc.id,
      groupId: (data['groupId'] ?? '').toString(),
      groupName: (data['groupName'] ?? '').toString(),
      inviteId: (data['inviteId'] ?? doc.id).toString(),
      createdBy: (data['createdBy'] ?? '').toString(),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      status: (data['status'] ?? 'pending').toString(),
      read: data['read'] == true,
    );
  }
}
