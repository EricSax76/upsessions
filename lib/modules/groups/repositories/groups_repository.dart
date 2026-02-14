import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/group_membership_entity.dart';
import '../models/group_dtos.dart';
import '../models/group_member.dart';
import 'groups_repository_base.dart';

part 'groups_repository_groups.dart';
part 'groups_repository_invites.dart';
part 'groups_repository_memberships.dart';
part 'groups_repository_utils.dart';

class GroupsRepository extends GroupsRepositoryBase
    with
        GroupsRepositoryGroups,
        GroupsRepositoryInvites,
        GroupsRepositoryMemberships {
  GroupsRepository({
    required super.firestore,
    required super.authRepository,
    required FirebaseStorage storage,
  }) : _storage = storage;

  final FirebaseStorage _storage;

  @override
  FirebaseStorage get storage => _storage;
}
