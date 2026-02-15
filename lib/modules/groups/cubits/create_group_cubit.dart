import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'create_group_state.dart';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit({
    required ImagePicker imagePicker,
  })  : _picker = imagePicker,
        super(const CreateGroupState());

  final ImagePicker _picker;

  Future<void> pickPhoto(ImageSource source) async {
    if (state.isPickingPhoto) return;
    emit(state.copyWith(isPickingPhoto: true));
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (file == null) {
        emit(state.copyWith(isPickingPhoto: false));
        return;
      }
      final bytes = await file.readAsBytes();
      final ext = _extensionFromName(file.name);
      emit(state.copyWith(
        photoBytes: bytes,
        photoExtension: ext,
        isPickingPhoto: false,
      ));
    } catch (_) {
      emit(state.copyWith(isPickingPhoto: false));
    }
  }

  void clearPhoto() {
    emit(state.copyWith(clearPhoto: true));
  }

  static String _extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }
}
