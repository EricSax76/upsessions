import '../../../core/locator/locator.dart';
import '../../messaging/repositories/chat_repository.dart';
import '../../../modules/musicians/models/musician_entity.dart';
import '../models/liked_musician.dart';

class ContactCardController {
  ContactCardController({ChatRepository? chatRepository})
    : _chatRepository = chatRepository ?? locate();

  final ChatRepository _chatRepository;

  String participantIdFor(LikedMusician musician) {
    final ownerId = musician.ownerId.trim();
    if (ownerId.isNotEmpty) {
      return ownerId;
    }
    return musician.id.trim();
  }

  Future<String> ensureThreadId(LikedMusician musician) async {
    final participantId = participantIdFor(musician);
    final thread = await _chatRepository.ensureThreadWithParticipant(
      participantId: participantId,
      participantName: musician.name,
    );
    return thread.id;
  }

  MusicianEntity toMusicianEntity(LikedMusician musician) {
    return MusicianEntity(
      id: musician.id,
      ownerId: musician.ownerId,
      name: musician.name,
      instrument: musician.instrument,
      city: musician.city,
      styles: musician.nonEmptyStyles,
      experienceYears: musician.experienceYears,
      photoUrl: musician.photoUrl,
      rating: musician.rating,
    );
  }
}
