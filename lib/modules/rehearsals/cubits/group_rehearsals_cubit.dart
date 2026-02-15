import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../../groups/models/group_dtos.dart';
import '../../groups/repositories/groups_repository.dart';
import '../../musicians/models/musician_entity.dart';
import '../../musicians/repositories/musicians_repository.dart';
import '../models/rehearsal_entity.dart';
import '../repositories/rehearsals_repository.dart';
import '../use_cases/create_rehearsal_use_case.dart';
import 'group_rehearsals_state.dart';

class GroupRehearsalsCubit extends Cubit<GroupRehearsalsState> {
  GroupRehearsalsCubit({
    required this.groupId,
    required GroupsRepository groupsRepository,
    required RehearsalsRepository rehearsalsRepository,
    required CreateRehearsalUseCase createRehearsalUseCase,
    required MusiciansRepository musiciansRepository,
    required AuthRepository authRepository,
  })  : _groupsRepository = groupsRepository,
        _rehearsalsRepository = rehearsalsRepository,
        _createRehearsalUseCase = createRehearsalUseCase,
        _musiciansRepository = musiciansRepository,
        _authRepository = authRepository,
        super(GroupRehearsalsLoading()) {
    _subscribe();
  }

  final String groupId;
  final GroupsRepository _groupsRepository;
  final RehearsalsRepository _rehearsalsRepository;
  final CreateRehearsalUseCase _createRehearsalUseCase;
  final MusiciansRepository _musiciansRepository;
  final AuthRepository _authRepository;

  final List<StreamSubscription> _subscriptions = [];
  GroupDoc? _group;
  String? _role;
  List<RehearsalEntity>? _rehearsals;
  bool _groupLoaded = false;
  bool _roleLoaded = false;
  bool _rehearsalsLoaded = false;

  void _subscribe() {
    _subscriptions.add(
      _groupsRepository.watchGroup(groupId).listen(
        (group) {
          _group = group;
          _groupLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      _groupsRepository.watchMyRole(groupId).listen(
        (role) {
          _role = role ?? '';
          _roleLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      _rehearsalsRepository.watchRehearsals(groupId).listen(
        (rehearsals) {
          _rehearsals = rehearsals;
          _rehearsalsLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );
  }

  Future<String> createRehearsal({
    required DateTime startsAt,
    required DateTime? endsAt,
    required String location,
    required String notes,
  }) => _createRehearsalUseCase(
    groupId: groupId,
    startsAt: startsAt,
    endsAt: endsAt,
    location: location,
    notes: notes,
    ensureActiveMember: true,
  );

  Future<List<MusicianEntity>> searchInviteCandidates({
    required String query,
  }) async {
    final trimmed = query.trim();
    final results = await _musiciansRepository.search(query: trimmed);
    final me = _authRepository.currentUser?.id;
    return results
        .where((musician) => musician.name.trim().isNotEmpty)
        .where((musician) => musician.ownerId.trim().isNotEmpty)
        .where((musician) => me == null || musician.ownerId != me)
        .toList();
  }

  Future<String> createInvite({required String targetUid}) =>
      _groupsRepository.createInvite(groupId: groupId, targetUid: targetUid);

  void _emitIfReady() {
    if (!_groupLoaded || !_roleLoaded || !_rehearsalsLoaded) {
      return;
    }

    emit(
      GroupRehearsalsLoaded(
        group: _group,
        role: _role ?? '',
        rehearsals: _rehearsals ?? const [],
      ),
    );
  }

  void _handleError(Object error) {
    emit(GroupRehearsalsError(error.toString()));
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
