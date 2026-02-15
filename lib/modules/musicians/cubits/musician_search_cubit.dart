import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../home/repositories/user_home_repository.dart';

import '../repositories/musicians_repository.dart';
import '../models/musician_entity.dart';

part 'musician_search_state.dart';

class MusicianSearchCubit extends Cubit<MusicianSearchState> {
  MusicianSearchCubit({
    required MusiciansRepository repository,
    required UserHomeRepository userHomeRepository,
  })  : _repository = repository,
        _userHomeRepository = userHomeRepository,
        super(const MusicianSearchState());

  final MusiciansRepository _repository;
  final UserHomeRepository _userHomeRepository;

  Future<void> loadFilters() async {
    if (state.areFiltersLoading || state.provinces.isNotEmpty) return;

    emit(state.copyWith(areFiltersLoading: true));
    try {
      final provinces = await _userHomeRepository.fetchProvinces();
      emit(state.copyWith(
        areFiltersLoading: false,
        provinces: provinces,
      ));
    } catch (_) {
      emit(state.copyWith(areFiltersLoading: false));
    }
  }

  Future<void> setProvince(String province) async {
    emit(state.copyWith(
      province: province,
      city: '',
      cities: const [],
      areFiltersLoading: true,
    ));

    if (province.isNotEmpty) {
      try {
        final cities = await _userHomeRepository.fetchCitiesForProvince(province);
        emit(state.copyWith(
          cities: cities,
          city: cities.isNotEmpty ? cities.first : '',
          areFiltersLoading: false,
        ));
      } catch (_) {
        emit(state.copyWith(areFiltersLoading: false));
      }
    } else {
      emit(state.copyWith(areFiltersLoading: false));
    }
  }

  void setCity(String city) {
    emit(state.copyWith(city: city));
  }

  void setInstrument(String instrument) {
    emit(state.copyWith(instrument: instrument));
  }

  void setStyle(String style) {
    emit(state.copyWith(style: style));
  }

  void setProfileType(String profileType) {
    emit(state.copyWith(profileType: profileType));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void clearFilters() {
    emit(state.copyWith(
      instrument: '',
      style: '',
      province: '',
      city: '',
      profileType: '',
      gender: '',
      cities: const [],
    ));
    search(query: '');
  }

  Future<void> search({String? query}) async {
    final effectiveQuery = query ?? state.query;
    
    emit(state.copyWith(
      isLoading: true,
      query: effectiveQuery,
      errorMessage: null,
    ));

    try {
      final results = await _repository.search(
        query: effectiveQuery,
        instrument: state.instrument,
        style: state.style,
        province: state.province,
        city: state.city,
        profileType: state.profileType,
        gender: state.gender,
      );
      emit(state.copyWith(isLoading: false, results: results));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
      ));
    }
  }
}
