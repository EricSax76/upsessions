import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


import '../../../../features/messaging/repositories/chat_repository.dart';

part 'announcement_detail_state.dart';

class AnnouncementDetailCubit extends Cubit<AnnouncementDetailState> {
  AnnouncementDetailCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const AnnouncementDetailState());

  final ChatRepository _chatRepository;

  Future<void> contactAuthor({
    required String authorId,
    required String authorName,
  }) async {
    if (state.status == AnnouncementDetailStatus.contacting) return;
    emit(state.copyWith(status: AnnouncementDetailStatus.contacting));

    try {
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: authorId,
        participantName: authorName,
      );
      emit(
        state.copyWith(
          status: AnnouncementDetailStatus.success,
          threadId: thread.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AnnouncementDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
