import 'package:equatable/equatable.dart';

class GroupMembershipEntity extends Equatable {
  const GroupMembershipEntity({
    required this.groupId,
    required this.groupName,
    required this.groupOwnerId,
    required this.role,
    this.photoUrl = '',
  });

  final String groupId;
  final String groupName;
  final String groupOwnerId;
  final String role; // owner|admin|member
  final String photoUrl;

  bool get canManageMembers => role == 'owner' || role == 'admin';

  @override
  List<Object?> get props => [groupId, groupName, groupOwnerId, role, photoUrl];
}
