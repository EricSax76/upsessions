import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

part 'matching_state.dart';

class MatchingCubit extends Cubit<MatchingState> {
  MatchingCubit({
    MatchingRepository? matchingRepository,
    AuthRepository? authRepository,
    MusiciansRepository? musiciansRepository,
  }) : _matchingRepository = matchingRepository ?? locate<MatchingRepository>(),
       _authRepository = authRepository ?? locate<AuthRepository>(),
       _musiciansRepository = musiciansRepository ?? locate<MusiciansRepository>(),
       super(const MatchingState());

  final MatchingRepository _matchingRepository;
  final AuthRepository _authRepository;
  final MusiciansRepository _musiciansRepository;

  Future<void> loadMatches() async {
    emit(state.copyWith(status: MatchingStatus.loading));

    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
          status: MatchingStatus.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      final myProfile = await _musiciansRepository.findById(user.id);
      if (myProfile == null || myProfile.influences.isEmpty) {
        emit(state.copyWith(
          status: MatchingStatus.success,
          matches: [],
        ));
        return;
      }

      final matches = await _matchingRepository.findMatches(
        myInfluences: myProfile.influences,
        myId: user.id,
      );

      emit(state.copyWith(
        status: MatchingStatus.success,
        matches: matches,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MatchingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
