import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/firebase_initializer.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_entity.dart';

part 'bootstrap_state.dart';

class BootstrapCubit extends Cubit<BootstrapState> {
  BootstrapCubit({required FirebaseInitializer firebaseInitializer, required AuthRepository authRepository})
      : _firebaseInitializer = firebaseInitializer,
        _authRepository = authRepository,
        super(const BootstrapState());

  final FirebaseInitializer _firebaseInitializer;
  final AuthRepository _authRepository;

  Future<void> initialize() async {
    emit(state.copyWith(status: BootstrapStatus.loading, errorMessage: null));
    try {
      await _firebaseInitializer.init();
      final user = _authRepository.currentUser;
      emit(
        state.copyWith(
          status: user != null ? BootstrapStatus.authenticated : BootstrapStatus.needsLogin,
          user: user,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: BootstrapStatus.error, errorMessage: error.toString()));
    }
  }
}
