import 'package:bloc/bloc.dart';
import '../../../../modules/events/models/event_entity.dart';
import '../repositories/manager_events_repository.dart';
import 'manager_event_form_state.dart';

class ManagerEventFormCubit extends Cubit<ManagerEventFormState> {
  ManagerEventFormCubit({required ManagerEventsRepository repository})
    : _repository = repository,
      super(const ManagerEventFormState());

  final ManagerEventsRepository _repository;

  void _safeEmit(ManagerEventFormState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> saveEvent(EventEntity event) async {
    _safeEmit(
      state.copyWith(isSaving: true, errorMessage: null, success: false),
    );
    try {
      await _repository.saveDraft(event);
      _safeEmit(state.copyWith(isSaving: false, success: true));
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
