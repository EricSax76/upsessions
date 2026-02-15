import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../repositories/groups_repository.dart';
import 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit({
    required this.groupId,
    required GroupsRepository groupsRepository,
    required ImagePicker imagePicker,
  })  : _groupsRepository = groupsRepository,
        _imagePicker = imagePicker,
        super(const GroupLoading()) {
    _subscription = _groupsRepository.watchGroup(groupId).listen(
      (group) => emit(GroupLoaded(group)),
      onError: (error) => emit(GroupError(error.toString())),
    );
  }

  final String groupId;
  final GroupsRepository _groupsRepository;
  final ImagePicker _imagePicker;
  StreamSubscription? _subscription;

  Future<XFile?> pickPhoto(ImageSource source) async {
    return _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  Future<void> uploadPhoto({
    required XFile image,
  }) async {
    // Optimistic or waiting update?
    // Since we stream the group, we just upload and wait for the stream to update.
    // However, we might want to show a loading indicator locally or return a Future so UI can show a snackbar.
    // The previous controller method returned a Future, so we keep that pattern for the UI to await.
    final bytes = await image.readAsBytes();
    final ext = image.path.split('.').last;

    await _groupsRepository.updateGroupPhoto(
      groupId: groupId,
      photoBytes: bytes,
      photoFileExtension: ext,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
