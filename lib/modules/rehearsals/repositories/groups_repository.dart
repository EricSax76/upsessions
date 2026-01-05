import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../cubits/group_membership_entity.dart';
import '../models/group_dtos.dart';
import 'rehearsals_repository_base.dart';

part 'groups_repository_groups.dart';
part 'groups_repository_invites.dart';
part 'groups_repository_memberships.dart';
part 'groups_repository_utils.dart';

class GroupsRepository extends RehearsalsRepositoryBase
    with
        GroupsRepositoryGroups,
        GroupsRepositoryInvites,
        GroupsRepositoryMemberships {
  GroupsRepository({
    super.firestore,
    super.authRepository,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  FirebaseStorage get storage => _storage;
}
