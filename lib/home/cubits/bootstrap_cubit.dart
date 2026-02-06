import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/services/firebase_initializer.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';

part 'bootstrap_state.dart';

class BootstrapCubit extends Cubit<BootstrapState> {
  BootstrapCubit({
    required FirebaseInitializer firebaseInitializer,
    required AuthRepository authRepository,
    required MusiciansRepository musiciansRepository,
    required StudiosRepository studiosRepository,
  }) : _firebaseInitializer = firebaseInitializer,
       _authRepository = authRepository,
       _musiciansRepository = musiciansRepository,
       _studiosRepository = studiosRepository,
       super(const BootstrapState());

  final FirebaseInitializer _firebaseInitializer;
  final AuthRepository _authRepository;
  final MusiciansRepository _musiciansRepository;
  final StudiosRepository _studiosRepository;

  Future<void> initialize() async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(status: BootstrapStatus.loading, errorMessage: null));
    try {
      await _firebaseInitializer.init();
      final user = _authRepository.currentUser;
      if (isClosed) {
        return;
      }
      if (user == null) {
        if (!isClosed) {
          emit(state.copyWith(status: BootstrapStatus.needsLogin, user: null));
        }
        return;
      }
      bool hasStudio = false;
      try {
        final studio = await _studiosRepository.getStudioByOwner(user.id);
        hasStudio = studio != null;
      } catch (_) {
        hasStudio = false;
      }
      if (isClosed) {
        return;
      }
      if (hasStudio) {
        emit(
          state.copyWith(status: BootstrapStatus.studioAuthenticated, user: user),
        );
        return;
      }

      final hasProfile = await _musiciansRepository.hasProfile(user.id);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: hasProfile
              ? BootstrapStatus.authenticated
              : BootstrapStatus.needsOnboarding,
          user: user,
        ),
      );
    } catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: BootstrapStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
