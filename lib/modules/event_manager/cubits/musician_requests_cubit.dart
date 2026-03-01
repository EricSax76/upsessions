import 'package:bloc/bloc.dart';
import '../repositories/musician_requests_repository.dart';
import 'musician_requests_state.dart';
import '../models/musician_request_entity.dart';

class MusicianRequestsCubit extends Cubit<MusicianRequestsState> {
  MusicianRequestsCubit({
    required MusicianRequestsRepository repository,
  })  : _repository = repository,
        super(const MusicianRequestsState());

  final MusicianRequestsRepository _repository;

  void _safeEmit(MusicianRequestsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadRequests() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final requests = await _repository.fetchManagerRequests();
      _safeEmit(state.copyWith(isLoading: false, requests: requests));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> sendRequest(MusicianRequestEntity request) async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.sendRequest(request);
      // Wait for network response and reload
      await loadRequests();
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> cancelRequest(String requestId) async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.deleteRequest(requestId);
      final updated = state.requests.where((r) => r.id != requestId).toList();
      _safeEmit(state.copyWith(isLoading: false, requests: updated));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
