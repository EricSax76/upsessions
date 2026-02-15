import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messaging/repositories/chat_repository.dart';
import '../../../modules/musicians/models/musician_entity.dart';
import '../models/liked_musician.dart';
import 'contact_card_state.dart';

class ContactCardCubit extends Cubit<ContactCardState> {
  ContactCardCubit({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ContactCardState());

  final ChatRepository _chatRepository;

  String _participantIdFor(LikedMusician musician) {
    final ownerId = musician.ownerId.trim();
    return ownerId.isNotEmpty ? ownerId : musician.id.trim();
  }

  Future<void> contact(LikedMusician musician) async {
    emit(state.copyWith(status: ContactCardStatus.contacting));
    try {
      final participantId = _participantIdFor(musician);
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: participantId,
        participantName: musician.name,
      );
      if (!isClosed) {
        emit(state.copyWith(
          status: ContactCardStatus.success,
          threadId: thread.id,
        ));
      }
    } catch (error) {
      debugPrint('[ContactCardCubit] Failed to contact: $error');
      if (!isClosed) {
        emit(state.copyWith(
          status: ContactCardStatus.error,
          errorMessage: error.toString(),
        ));
      }
    }
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
