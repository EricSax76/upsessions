import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

import '../models/musician_entity.dart';

class MusicianDetailController {
  MusicianDetailController({
    ChatRepository? chatRepository,
    GroupsRepository? groupsRepository,
  }) : _chatRepository = chatRepository ?? locate(),
       _groupsRepository = groupsRepository ?? locate();

  final ChatRepository _chatRepository;
  final GroupsRepository _groupsRepository;

  GroupsRepository get groupsRepository => _groupsRepository;

  String participantIdFor(MusicianEntity musician) {
    final ownerId = musician.ownerId.trim();
    return ownerId.isNotEmpty ? ownerId : musician.id.trim();
  }

  Future<String> ensureThreadId(MusicianEntity musician) async {
    final participantId = participantIdFor(musician);
    final thread = await _chatRepository.ensureThreadWithParticipant(
      participantId: participantId,
      participantName: musician.name,
    );
    return thread.id;
  }
}
