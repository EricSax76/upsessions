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
      final groups = await _groupsRepository.watchMyGroups().first;
      final allRehearsals = <RehearsalEntity>[];
      for (final group in groups) {
        final rehearsals = await _rehearsalsRepository.getRehearsals(
          group.groupId,
        );
        allRehearsals.addAll(rehearsals);
      }
      allRehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      emit(state.copyWith(isLoading: false, rehearsals: allRehearsals));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No pudimos cargar tu agenda. Intenta más tarde.',
        ),
      );
    }
  }
}
