import 'package:flutter_bloc/flutter_bloc.dart';
import '../../musicians/repositories/musicians_repository.dart';
import '../../groups/repositories/groups_repository.dart';
import 'invite_musician_state.dart';

class InviteMusicianCubit extends Cubit<InviteMusicianState> {
  InviteMusicianCubit({
    required this.groupId,
    required this.musiciansRepository,
    required this.groupsRepository,
  }) : super(const InviteMusicianState.initial());

  final String groupId;
  final MusiciansRepository musiciansRepository;
  final GroupsRepository groupsRepository;

  int _searchToken = 0;

  Future<void> onQueryChanged(String value) async {
    final trimmed = value.trim();
    final token = ++_searchToken;

    if (trimmed.isEmpty) {
      if (isClosed) return;
      emit(state.copyWith(
        query: '',
        isLoading: false,
        results: const [],
      ));
      return;
    }

    if (isClosed) return;
    emit(state.copyWith(
      query: trimmed,
      isLoading: true,
      results: const [],
    ));

    try {
      final results = await musiciansRepository.search(query: trimmed);
      if (isClosed || token != _searchToken) return;
      emit(state.copyWith(isLoading: false, results: results));
    } catch (_) {
      if (isClosed || token != _searchToken) return;
      emit(state.copyWith(isLoading: false, results: const []));
    }
  }

  Future<String> invite(String targetUid) async {
    return groupsRepository.createInvite(
      groupId: groupId,
      targetUid: targetUid,
    );
  }
}
