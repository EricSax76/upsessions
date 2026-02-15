import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../features/messaging/repositories/chat_repository.dart';
import '../../groups/repositories/groups_repository.dart';
import '../models/musician_entity.dart';

part 'musician_detail_state.dart';

class MusicianDetailCubit extends Cubit<MusicianDetailState> {
  MusicianDetailCubit({
    required ChatRepository chatRepository,
    required this.groupsRepository,
  })  : _chatRepository = chatRepository,
        super(const MusicianDetailInitial());

  final ChatRepository _chatRepository;
  final GroupsRepository groupsRepository;

  String getParticipantId(MusicianEntity musician) {
    final ownerId = musician.ownerId.trim();
    return ownerId.isNotEmpty ? ownerId : musician.id.trim();
  }

  Future<void> contactMusician(MusicianEntity musician) async {
    emit(const MusicianDetailContacting());
    try {
      final participantId = getParticipantId(musician);
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: participantId,
        participantName: musician.name,
      );
      emit(MusicianDetailContactSuccess(thread.id));
    } catch (e) {
      emit(MusicianDetailError(e.toString()));
    }
  }
}
