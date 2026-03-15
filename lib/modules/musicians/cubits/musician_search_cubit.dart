import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../features/home/repositories/home_metadata_repository.dart';

import '../repositories/musicians_repository.dart';
import '../models/musician_entity.dart';

part 'musician_search_state.dart';

class MusicianSearchCubit extends Cubit<MusicianSearchState> {
  MusicianSearchCubit({
    required MusiciansRepository repository,
    required HomeMetadataRepository metadataRepository,
  }) : _repository = repository,
       _metadataRepository = metadataRepository,
       super(const MusicianSearchState());

  final MusiciansRepository _repository;
  final HomeMetadataRepository _metadataRepository;
  static const Duration _queryDebounceDuration = Duration(milliseconds: 500);
  Timer? _queryDebounce;

  void onQueryChanged(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery == state.query) {
      return;
    }

    emit(state.copyWith(query: normalizedQuery, errorMessage: null));
    _queryDebounce?.cancel();
    _queryDebounce = Timer(_queryDebounceDuration, () {
      search(query: normalizedQuery);
    });
  }

  Future<void> searchNow({String? query}) async {
    _queryDebounce?.cancel();
    await search(query: query?.trim());
  }

  Future<void> loadFilters() async {
    if (state.areFiltersLoading || state.provinces.isNotEmpty) return;

    emit(state.copyWith(areFiltersLoading: true));
    try {
      final provinces = await _metadataRepository.fetchProvinces();
      emit(state.copyWith(areFiltersLoading: false, provinces: provinces));
    } catch (_) {
      emit(state.copyWith(areFiltersLoading: false));
    }
  }

  Future<void> setProvince(String province) async {
    emit(
      state.copyWith(
        province: province,
        city: '',
        cities: const [],
        areFiltersLoading: true,
      ),
    );

    if (province.isNotEmpty) {
      try {
        final cities = await _metadataRepository.fetchCitiesForProvince(
          province,
        );
        emit(
          state.copyWith(
            cities: cities,
            city: cities.isNotEmpty ? cities.first : '',
            areFiltersLoading: false,
          ),
        );
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

  Future<void> clearFilters() async {
    _queryDebounce?.cancel();
    emit(
      state.copyWith(
        query: '',
        instrument: '',
        style: '',
        province: '',
        city: '',
        profileType: '',
        gender: '',
        cities: const [],
      ),
    );
    await search(query: '');
  }

  Future<void> search({String? query}) async {
    final effectiveQuery = (query ?? state.query).trim();

    emit(
      state.copyWith(
        isLoading: true,
        query: effectiveQuery,
        errorMessage: null,
      ),
    );

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
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _queryDebounce?.cancel();
    return super.close();
  }
}
