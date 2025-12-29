import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/musicians_repository.dart';
import '../domain/musician_entity.dart';

part 'musician_search_state.dart';

class MusicianSearchCubit extends Cubit<MusicianSearchState> {
  MusicianSearchCubit({required MusiciansRepository repository})
      : _repository = repository,
        super(const MusicianSearchState());

  final MusiciansRepository _repository;

  Future<void> search({
    String? query,
    String instrument = '',
    String style = '',
    String province = '',
    String city = '',
    String profileType = '',
    String gender = '',
  }) async {
    final normalizedQuery = query ?? state.query;
    emit(state.copyWith(isLoading: true, query: normalizedQuery, errorMessage: null));
    try {
      final results = await _repository.search(
        query: normalizedQuery,
        instrument: instrument,
        style: style,
        province: province,
        city: city,
        profileType: profileType,
        gender: gender,
      );
      emit(state.copyWith(isLoading: false, results: results));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.')); 
    }
  }
}
