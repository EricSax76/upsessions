import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';

import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'musician_onboarding_state.dart';

class MusicianOnboardingCubit extends Cubit<MusicianOnboardingState> {
  MusicianOnboardingCubit({required MusiciansRepository repository})
    : _repository = repository,
      super(const MusicianOnboardingState());

  final MusiciansRepository _repository;

  void toggleAvailableForHire(bool value) {
    emit(state.copyWith(availableForHire: value));
  }

  void previousStep() {
    if (state.currentStep <= 0) return;
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  void nextStep() {
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void addInfluence(String style, String artist) {
    final updated = AffinityFlow.addInfluence(
      influences: state.influences,
      style: style,
      artist: artist,
    );
    if (identical(updated, state.influences)) return;
    emit(state.copyWith(influences: updated));
  }

  void removeInfluence(String style, String artist) {
    final updated = AffinityFlow.removeInfluence(
      influences: state.influences,
      style: style,
      artist: artist,
    );
    if (identical(updated, state.influences)) return;
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
        availableForHire: state.availableForHire,
      );
      if (isClosed) return;
      emit(state.copyWith(status: MusicianOnboardingStatus.saved));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MusicianOnboardingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
