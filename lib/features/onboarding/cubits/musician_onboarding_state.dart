import 'package:equatable/equatable.dart';

enum MusicianOnboardingStatus { idle, saving, saved, error }

class MusicianOnboardingState extends Equatable {
  const MusicianOnboardingState({
    this.currentStep = 0,
    this.status = MusicianOnboardingStatus.idle,
    this.influences = const {},
    this.errorMessage,
    this.availableForHire = false,
  });

  final int currentStep;
  final MusicianOnboardingStatus status;
  final Map<String, List<String>> influences;
  final String? errorMessage;
  final bool availableForHire;

  bool get isSaving => status == MusicianOnboardingStatus.saving;

  MusicianOnboardingState copyWith({
    int? currentStep,
    MusicianOnboardingStatus? status,
    Map<String, List<String>>? influences,
    String? errorMessage,
    bool? availableForHire,
  }) {
    return MusicianOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      influences: influences ?? this.influences,
      errorMessage: errorMessage,
      availableForHire: availableForHire ?? this.availableForHire,
    );
  }

  @override
  List<Object?> get props => [currentStep, status, influences, errorMessage, availableForHire];
}
