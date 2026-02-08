import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../core/locator/locator.dart';

import '../repositories/user_home_repository.dart';
import 'user_home_state.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit({UserHomeRepository? repository})
    : _repository = repository ?? locate<UserHomeRepository>(),
      super(const UserHomeState());

  final UserHomeRepository _repository;

  Future<void> loadHome() async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(status: UserHomeStatus.loading, errorMessage: null));
    try {
      final recommendedFuture = _repository.fetchRecommendedMusicians();
      final newMusiciansFuture = _repository.fetchNewMusicians();
      final announcementsFuture = _repository.fetchRecentAnnouncements();
      final categoriesFuture = _repository.fetchInstrumentCategories();
      final eventsFuture = _repository.fetchUpcomingEvents();
      final upcomingRehearsalsFuture = _repository.fetchUpcomingRehearsals();
      final provincesFuture = _repository.fetchProvinces();

      final recommended = await recommendedFuture;
      final newMusicians = await newMusiciansFuture;
      final announcements = await announcementsFuture;
      final categories = await categoriesFuture;
      final events = await eventsFuture;
      final upcomingRehearsals = await upcomingRehearsalsFuture;
      final provinces = await provincesFuture;
      if (isClosed) {
        return;
      }
      final shouldClearLocation = provinces.isEmpty;
      emit(
        state.copyWith(
          status: UserHomeStatus.ready,
          recommended: recommended,
          newMusicians: newMusicians,
          announcements: announcements,
          categories: categories,
          events: events,
          upcomingRehearsals: upcomingRehearsals,
          provinces: provinces,
          province: shouldClearLocation ? '' : state.province,
          city: shouldClearLocation ? '' : state.city,
          cities: shouldClearLocation ? const [] : state.cities,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: UserHomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void selectProvince(String value) {
    emit(state.copyWith(province: value));
    unawaited(_loadCitiesForProvince(value));
  }

  void selectCity(String value) {
    emit(state.copyWith(city: value));
  }

  void selectInstrument(String value) {
    emit(state.copyWith(instrument: value));
  }

  void selectStyle(String value) {
    emit(state.copyWith(style: value));
  }

  void selectProfileType(String value) {
    emit(state.copyWith(profileType: value));
  }

  void selectGender(String value) {
    emit(state.copyWith(gender: value));
  }

  void resetFilters() {
    emit(
      state.copyWith(
        instrument: '',
        style: '',
        profileType: '',
        gender: '',
        province: '',
        city: '',
        cities: const [],
      ),
    );
  }

  Future<void> _loadCitiesForProvince(String value) async {
    if (value.trim().isEmpty) {
      emit(state.copyWith(cities: const [], city: ''));
      return;
    }
    final cities = await _repository.fetchCitiesForProvince(value);
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        cities: cities,
        city: cities.isNotEmpty ? cities.first : '',
      ),
    );
  }
}
