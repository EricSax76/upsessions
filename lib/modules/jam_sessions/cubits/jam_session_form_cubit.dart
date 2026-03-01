import 'package:bloc/bloc.dart';
import '../models/jam_session_entity.dart';
import '../repositories/jam_sessions_repository.dart';
import 'jam_session_form_state.dart';

class JamSessionFormCubit extends Cubit<JamSessionFormState> {
  JamSessionFormCubit({
    required JamSessionsRepository repository,
  })  : _repository = repository,
        super(const JamSessionFormState());

  final JamSessionsRepository _repository;

  void _safeEmit(JamSessionFormState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> saveSession(JamSessionEntity session) async {
    _safeEmit(state.copyWith(isSaving: true, errorMessage: null, success: false));
    try {
      await _repository.saveDraft(session);
      _safeEmit(state.copyWith(isSaving: false, success: true));
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
