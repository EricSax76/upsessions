import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../groups/repositories/groups_repository.dart';
import '../repositories/rehearsals_repository.dart';
import '../models/rehearsal_entity.dart';

part 'agenda_state.dart';

class AgendaCubit extends Cubit<AgendaState> {
  AgendaCubit({
    required RehearsalsRepository rehearsalsRepository,
    required GroupsRepository groupsRepository,
  }) : _rehearsalsRepository = rehearsalsRepository,
       _groupsRepository = groupsRepository,
       super(const AgendaState()) {
    fetchRehearsals();
  }

  final RehearsalsRepository _rehearsalsRepository;
  final GroupsRepository _groupsRepository;

  Future<void> fetchRehearsals() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final allRehearsals = await _rehearsalsRepository.getMyRehearsals();
      allRehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      emit(state.copyWith(isLoading: false, rehearsals: allRehearsals));
    } catch (_) {
      try {
        final fallback = await _fetchRehearsalsByGroup();
        fallback.sort((a, b) => a.startsAt.compareTo(b.startsAt));
        emit(state.copyWith(isLoading: false, rehearsals: fallback));
      } catch (_) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'No pudimos cargar tu agenda. Intenta más tarde.',
          ),
        );
      }
    }
  }

  Future<List<RehearsalEntity>> _fetchRehearsalsByGroup() async {
    final groups = await _groupsRepository.watchMyGroups().first;
    final groupIds = groups.map((group) => group.groupId).toSet().toList();
    final rehearsalsByGroup = await Future.wait(
      groupIds.map((groupId) async {
        try {
          return await _rehearsalsRepository.getRehearsals(groupId);
        } catch (_) {
          return const <RehearsalEntity>[];
        }
      }),
    );
    return rehearsalsByGroup.expand((rehearsals) => rehearsals).toList();
  }
}
