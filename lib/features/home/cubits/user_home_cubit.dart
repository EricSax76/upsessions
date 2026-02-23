import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repositories/home_announcements_repository.dart';
import '../repositories/home_events_repository.dart';
import '../repositories/home_metadata_repository.dart';
import '../repositories/home_musicians_repository.dart';
import '../repositories/home_rehearsals_repository.dart';
import 'user_home_state.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit({
    required HomeMusiciansRepository musiciansRepository,
    required HomeAnnouncementsRepository announcementsRepository,
    required HomeMetadataRepository metadataRepository,
    required HomeEventsRepository eventsRepository,
    required HomeRehearsalsRepository rehearsalsRepository,
  }) : _musiciansRepository = musiciansRepository,
       _announcementsRepository = announcementsRepository,
       _metadataRepository = metadataRepository,
       _eventsRepository = eventsRepository,
       _rehearsalsRepository = rehearsalsRepository,
       super(const UserHomeState());

  final HomeMusiciansRepository _musiciansRepository;
  final HomeAnnouncementsRepository _announcementsRepository;
  final HomeMetadataRepository _metadataRepository;
  final HomeEventsRepository _eventsRepository;
  final HomeRehearsalsRepository _rehearsalsRepository;

  Future<void> loadHome() async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(status: UserHomeStatus.loading, errorMessage: null));
    try {
      final recommendedFuture = _musiciansRepository
          .fetchRecommendedMusicians();
      final newMusiciansFuture = _musiciansRepository.fetchNewMusicians();
      final announcementsFuture = _announcementsRepository
          .fetchRecentAnnouncements();
      final categoriesFuture = _metadataRepository.fetchInstrumentCategories();
      final eventsFuture = _eventsRepository.fetchUpcomingEvents();
      final upcomingRehearsalsFuture = _rehearsalsRepository
          .fetchUpcomingRehearsals();
      final provincesFuture = _metadataRepository.fetchProvinces();

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
    final cities = await _metadataRepository.fetchCitiesForProvince(value);
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
