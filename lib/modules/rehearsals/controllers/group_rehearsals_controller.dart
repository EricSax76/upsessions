import '../../../core/locator/locator.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../musicians/repositories/musicians_repository.dart';
import '../../musicians/models/musician_entity.dart';
import '../models/create_rehearsal_use_case.dart';
import '../../groups/models/group_dtos.dart';
import '../../groups/repositories/groups_repository.dart';
import '../repositories/rehearsals_repository.dart';
import '../models/rehearsal_entity.dart';

class GroupRehearsalsController {
  GroupRehearsalsController({
    required GroupsRepository groupsRepository,
    required RehearsalsRepository rehearsalsRepository,
    required CreateRehearsalUseCase createRehearsalUseCase,
    required MusiciansRepository musiciansRepository,
    required AuthRepository authRepository,
  }) : _groupsRepository = groupsRepository,
       _rehearsalsRepository = rehearsalsRepository,
       _createRehearsalUseCase = createRehearsalUseCase,
       _musiciansRepository = musiciansRepository,
       _authRepository = authRepository;

  factory GroupRehearsalsController.fromLocator() => GroupRehearsalsController(
    groupsRepository: locate<GroupsRepository>(),
    rehearsalsRepository: locate<RehearsalsRepository>(),
    createRehearsalUseCase: locate<CreateRehearsalUseCase>(),
    musiciansRepository: locate<MusiciansRepository>(),
    authRepository: locate<AuthRepository>(),
  );

  final GroupsRepository _groupsRepository;
  final RehearsalsRepository _rehearsalsRepository;
  final CreateRehearsalUseCase _createRehearsalUseCase;
  final MusiciansRepository _musiciansRepository;
  final AuthRepository _authRepository;

  Stream<String> watchGroupName(String groupId) =>
      _groupsRepository.watchGroupName(groupId);

  Stream<String?> watchMyRole(String groupId) =>
      _groupsRepository.watchMyRole(groupId);

  Stream<GroupDoc> watchGroup(String groupId) =>
      _groupsRepository.watchGroup(groupId);

  Stream<List<RehearsalEntity>> watchRehearsals(String groupId) =>
      _rehearsalsRepository.watchRehearsals(groupId);

  Future<String> createRehearsal({
    required String groupId,
    required DateTime startsAt,
    required DateTime? endsAt,
    required String location,
    required String notes,
  }) => _createRehearsalUseCase(
    groupId: groupId,
    startsAt: startsAt,
    endsAt: endsAt,
    location: location,
    notes: notes,
    ensureActiveMember: true,
  );

  Future<List<MusicianEntity>> searchInviteCandidates({
    required String query,
  }) async {
    final trimmed = query.trim();
    final results = await _musiciansRepository.search(query: trimmed);
    final me = _authRepository.currentUser?.id;
    return results
        .where((musician) => musician.name.trim().isNotEmpty)
        .where((musician) => musician.ownerId.trim().isNotEmpty)
        .where((musician) => me == null || musician.ownerId != me)
        .toList();
  }

  Future<String> createInvite({
    required String groupId,
    required String targetUid,
  }) => _groupsRepository.createInvite(groupId: groupId, targetUid: targetUid);
}
