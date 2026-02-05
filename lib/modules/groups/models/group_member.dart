import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  const GroupMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    this.photoUrl,
    this.instrument,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final String? photoUrl;
  final String? instrument;

  @override
  List<Object?> get props => [id, name, role, status, photoUrl, instrument];
}
