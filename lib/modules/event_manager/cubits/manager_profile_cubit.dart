import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/modules/profile/ui/widgets/account/account_photo_flow.dart';

import 'event_manager_auth_cubit.dart';
import 'event_manager_auth_state.dart';
import 'manager_profile_state.dart';

class ManagerProfileCubit extends Cubit<ManagerProfileState> {
  ManagerProfileCubit({required EventManagerAuthCubit authCubit})
      : _authCubit = authCubit,
        super(const ManagerProfileState());

  final EventManagerAuthCubit _authCubit;
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();

  void _safeEmit(ManagerProfileState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> stagePhoto(ImageSource source) async {
    try {
      final file = await _photoFlow.pickProfilePhoto(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      _safeEmit(state.copyWith(
        pendingPhotoBytes: bytes,
        pendingPhotoExtension: AccountPhotoFlow.extensionFromName(file.name),
        feedbackMessage: 'Foto seleccionada. Pulsa "Guardar cambios".',
        feedbackIsError: false,
      ));
    } catch (error) {
      _safeEmit(state.copyWith(
        feedbackMessage: 'No se pudo seleccionar la foto: $error',
        feedbackIsError: true,
      ));
    }
  }

  Future<void> saveChanges(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _safeEmit(state.copyWith(
        feedbackMessage: 'El nombre es obligatorio.',
        feedbackIsError: true,
      ));
      return;
    }

    _safeEmit(state.copyWith(isSaving: true));
    await _authCubit.updateProfile(
      managerName: trimmedName,
      photoBytes: state.pendingPhotoBytes,
      photoExtension: state.pendingPhotoExtension ?? 'jpg',
    );

    final authState = _authCubit.state;
    if (authState.status == EventManagerAuthStatus.authenticated) {
      _safeEmit(state.copyWith(
        isSaving: false,
        pendingPhotoBytes: null,
        pendingPhotoExtension: null,
        feedbackMessage: 'Cambios guardados.',
        feedbackIsError: false,
      ));
    } else if (authState.status == EventManagerAuthStatus.error) {
      _safeEmit(state.copyWith(
        isSaving: false,
        feedbackMessage: authState.errorMessage ?? 'No se pudieron guardar los cambios.',
        feedbackIsError: true,
      ));
    } else {
      _safeEmit(state.copyWith(isSaving: false));
    }
  }

  void clearFeedback() {
    _safeEmit(state.copyWith(feedbackMessage: null));
  }
}
