import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/auth/repositories/auth_repository.dart';
import '../../../modules/auth/models/user_entity.dart';
import '../repositories/contacts_repository.dart';
import '../models/liked_musician.dart';
import 'liked_musicians_state.dart';

class LikedMusiciansCubit extends Cubit<LikedMusiciansState> {
  LikedMusiciansCubit({
    required ContactsRepository contactsRepository,
    required AuthRepository authRepository,
  })  : _contactsRepository = contactsRepository,
        _authRepository = authRepository,
        super(const LikedMusiciansState()) {
    _authSubscription = _authRepository.authStateChanges.listen(_handleAuth);
    _handleAuth(_authRepository.currentUser);
  }

  final ContactsRepository _contactsRepository;
  final AuthRepository _authRepository;

  StreamSubscription<List<LikedMusician>>? _contactsSubscription;
  StreamSubscription<UserEntity?>? _authSubscription;
  String? _currentOwnerId;

  Future<void> toggleLike(LikedMusician musician) async {
    final ownerId = _currentOwnerId;
    if (ownerId == null) {
      debugPrint(
        '[LikedMusiciansCubit] toggleLike skipped: no authenticated user.',
      );
      return;
    }

    if (state.isLiked(musician.id)) {
      // Optimistic remove
      final previous = Map<String, LikedMusician>.of(state.contacts);
      final updated = Map<String, LikedMusician>.of(state.contacts)
        ..remove(musician.id);
      emit(state.copyWith(contacts: updated));
      try {
        await _contactsRepository.deleteContact(
          ownerId: ownerId,
          contactId: musician.id,
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[LikedMusiciansCubit] Failed to delete contact ${musician.id}: $error',
        );
        if (kDebugMode) {
          debugPrintStack(stackTrace: stackTrace);
        }
        if (!isClosed) {
          emit(state.copyWith(contacts: previous));
        }
      }
      return;
    }

    // Optimistic add
    final updated = Map<String, LikedMusician>.of(state.contacts)
      ..[musician.id] = musician;
    emit(state.copyWith(contacts: updated));
    try {
      await _contactsRepository.saveContact(
        ownerId: ownerId,
        contact: musician,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LikedMusiciansCubit] Failed to save contact ${musician.id}: $error',
      );
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!isClosed) {
        final reverted = Map<String, LikedMusician>.of(state.contacts)
          ..remove(musician.id);
        emit(state.copyWith(contacts: reverted));
      }
    }
  }

  Future<void> remove(String musicianId) async {
    final ownerId = _currentOwnerId;
    if (ownerId == null) return;

    final removed = state.contacts[musicianId];
    if (removed == null) return;

    final updated = Map<String, LikedMusician>.of(state.contacts)
      ..remove(musicianId);
    emit(state.copyWith(contacts: updated));

    try {
      await _contactsRepository.deleteContact(
        ownerId: ownerId,
        contactId: musicianId,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[LikedMusiciansCubit] Failed to remove contact $musicianId: $error',
      );
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!isClosed) {
        final reverted = Map<String, LikedMusician>.of(state.contacts)
          ..[musicianId] = removed;
        emit(state.copyWith(contacts: reverted));
      }
    }
  }

  void sync(LikedMusician musician) {
    if (!state.isLiked(musician.id)) return;

    final updated = Map<String, LikedMusician>.of(state.contacts)
      ..[musician.id] = musician;
    emit(state.copyWith(contacts: updated));

    final ownerId = _currentOwnerId;
    if (ownerId == null) return;
    unawaited(
      _contactsRepository.saveContact(ownerId: ownerId, contact: musician),
    );
  }

  void _handleAuth(UserEntity? user) {
    _currentOwnerId = user?.id;
    _contactsSubscription?.cancel();
    _contactsSubscription = null;

    emit(const LikedMusiciansState());

    if (user == null) return;

    emit(state.copyWith(status: LikedMusiciansStatus.loading));
    _contactsSubscription = _contactsRepository
        .watchContacts(user.id)
        .listen(
          _handleContactsUpdate,
          onError: (error, stackTrace) {
            debugPrint(
              '[LikedMusiciansCubit] Contacts stream error: $error',
            );
            if (kDebugMode) {
              debugPrintStack(stackTrace: stackTrace);
            }
            if (!isClosed) {
              emit(state.copyWith(
                status: LikedMusiciansStatus.error,
                errorMessage: error.toString(),
              ));
            }
          },
        );
  }

  void _handleContactsUpdate(List<LikedMusician> items) {
    if (isClosed) return;
    final map = {for (final item in items) item.id: item};
    emit(state.copyWith(
      status: LikedMusiciansStatus.loaded,
      contacts: map,
    ));
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
