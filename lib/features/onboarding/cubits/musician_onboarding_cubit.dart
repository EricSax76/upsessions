import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'musician_onboarding_state.dart';

class MusicianOnboardingCubit extends Cubit<MusicianOnboardingState> {
  MusicianOnboardingCubit({required MusiciansRepository repository})
      : _repository = repository,
        super(const MusicianOnboardingState());

  final MusiciansRepository _repository;

  void previousStep() {
    if (state.currentStep <= 0) return;
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  void nextStep() {
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void addInfluence(String style, String artist) {
    if (style.trim().isEmpty || artist.trim().isEmpty) return;
    final updated = Map<String, List<String>>.of(state.influences);
    final artists = List<String>.of(updated[style] ?? []);
    if (artists.any((a) => a.toLowerCase() == artist.toLowerCase())) return;
    artists.add(artist.trim());
    updated[style] = artists;
    emit(state.copyWith(influences: updated));
  }

  void removeInfluence(String style, String artist) {
    final updated = Map<String, List<String>>.of(state.influences);
    if (!updated.containsKey(style)) return;
    final artists = List<String>.of(updated[style]!);
    artists.remove(artist);
    if (artists.isEmpty) {
      updated.remove(style);
    } else {
      updated[style] = artists;
    }
    emit(state.copyWith(influences: updated));
  }

  Future<void> submit({
    required String musicianId,
    required String name,
    required String instrument,
    required String city,
    required List<String> styles,
    required int experienceYears,
    String? photoUrl,
    String? bio,
  }) async {
    emit(state.copyWith(status: MusicianOnboardingStatus.saving));
    try {
      await _repository.saveProfile(
        musicianId: musicianId,
        name: name,
        instrument: instrument,
        city: city,
        styles: styles,
        experienceYears: experienceYears,
        photoUrl: photoUrl,
        bio: bio,
        influences: state.influences,
      );
      if (isClosed) return;
      emit(state.copyWith(status: MusicianOnboardingStatus.saved));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: MusicianOnboardingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
