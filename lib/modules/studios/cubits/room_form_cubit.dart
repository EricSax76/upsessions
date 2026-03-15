import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/room_entity.dart';
import 'my_studio_cubit.dart';
import 'room_form_state.dart';
import '../ui/forms/room_form_draft.dart';

typedef RoomPhotosUploader = Future<List<String>> Function(String roomId);

class RoomFormCubit extends Cubit<RoomFormState> {
  RoomFormCubit({
    required MyStudioCubit studioCubit,
    RoomEntity? initialRoom,
    String Function()? idGenerator,
  }) : _studioCubit = studioCubit,
       _idGenerator = idGenerator ?? (() => const Uuid().v4()),
       draft = RoomFormDraft(initialRoom: initialRoom),
       super(const RoomFormState());

  final MyStudioCubit _studioCubit;
  final String Function() _idGenerator;

  final RoomFormDraft draft;

  Future<void> submit({
    required String studioId,
    required RoomPhotosUploader uploadPhotos,
    RoomEntity? existingRoom,
  }) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final roomId = existingRoom?.id ?? _idGenerator();
      final photos = await uploadPhotos(roomId);
      final room = draft.toRoomEntity(
        studioId: studioId,
        roomId: roomId,
        photos: photos,
        fallback: existingRoom,
      );
      await _studioCubit.createRoom(room);
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    draft.dispose();
    return super.close();
  }
}
