import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/services/firebase_initializer.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/auth/domain/user_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

part 'bootstrap_state.dart';

class BootstrapCubit extends Cubit<BootstrapState> {
  BootstrapCubit({
    required FirebaseInitializer firebaseInitializer,
    required AuthRepository authRepository,
    required MusiciansRepository musiciansRepository,
  }) : _firebaseInitializer = firebaseInitializer,
       _authRepository = authRepository,
       _musiciansRepository = musiciansRepository,
       super(const BootstrapState());

  final FirebaseInitializer _firebaseInitializer;
  final AuthRepository _authRepository;
  final MusiciansRepository _musiciansRepository;

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
