import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/hire_musicians_state.dart';

class HireMusiciansCubit extends Cubit<HireMusiciansState> {
  HireMusiciansCubit({required MusiciansRepository repository})
      : _repository = repository,
        super(const HireMusiciansState());

  final MusiciansRepository _repository;
  Timer? _debounceTimer;

  Future<void> loadMusicians() async {
    await search(state.searchQuery);
  }

  Future<void> search(String query) async {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (isClosed) return;
      emit(state.copyWith(isLoading: true, searchQuery: query, error: null));
      try {
        final results = await _repository.searchAvailableForHire(query: query);
        if (isClosed) return;
        emit(state.copyWith(isLoading: false, musicians: results));
      } catch (e) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
