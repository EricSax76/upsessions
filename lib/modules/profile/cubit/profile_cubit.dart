import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';

import 'package:upsessions/modules/auth/models/auth_exceptions.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository profileRepository,
    required AuthCubit authCubit,
  }) : _profileRepository = profileRepository,
       _authCubit = authCubit,
       super(const ProfileState()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      final user = authState.user;
      if (user == null) {
        emit(const ProfileState());
        return;
      }
      unawaited(Future.microtask(() => refreshProfile(profileId: user.id)));
    });

    final user = _authCubit.state.user;
    if (user != null) {
      unawaited(Future.microtask(() => refreshProfile(profileId: user.id)));
    }
  }

  final ProfileRepository _profileRepository;
  final AuthCubit _authCubit;
  late StreamSubscription _authSubscription;

  Future<void> refreshProfile({String? profileId}) async {
    final id = profileId ?? _authCubit.state.user?.id;
    if (id == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'You must be logged in to load a profile.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final dto = await _profileRepository.fetchProfile(profileId: id);
      emit(
        state.copyWith(profile: dto.toEntity(), status: ProfileStatus.success),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not load profile: $error',
        ),
      );
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final dto = await _profileRepository.updateProfile(profile);
      emit(
        state.copyWith(profile: dto.toEntity(), status: ProfileStatus.success),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not update profile: $error',
        ),
      );
    }
  }

  Future<void> updateProfilePhoto(
    Uint8List bytes, {
    required String fileExtension,
  }) async {
    final user = _authCubit.state.user;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'You must be logged in to update your photo.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final dto = await _profileRepository.uploadProfilePhoto(
        userId: user.id,
        bytes: bytes,
        fileExtension: fileExtension,
      );
      emit(
        state.copyWith(profile: dto.toEntity(), status: ProfileStatus.success),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not update photo: $error',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
