import '../../groups/repositories/groups_repository.dart';
import '../repositories/rehearsals_repository.dart';

class CreateRehearsalUseCase {
  CreateRehearsalUseCase({
    required GroupsRepository groupsRepository,
    required RehearsalsRepository rehearsalsRepository,
  }) : _groupsRepository = groupsRepository,
       _rehearsalsRepository = rehearsalsRepository;

  final GroupsRepository _groupsRepository;
  final RehearsalsRepository _rehearsalsRepository;

  Future<String> call({
    required String groupId,
    required DateTime startsAt,
    DateTime? endsAt,
    String location = '',
    String notes = '',
    bool ensureActiveMember = false,
  }) async {
    if (ensureActiveMember) {
      final isActive = await _groupsRepository.isActiveMember(groupId);
      if (!isActive) {
        throw Exception('No eres miembro activo de este grupo.');
      }
    }

    return _rehearsalsRepository.createRehearsal(
      groupId: groupId,
      startsAt: startsAt,
      endsAt: endsAt,
      location: location,
      notes: notes,
    );
  }
}
