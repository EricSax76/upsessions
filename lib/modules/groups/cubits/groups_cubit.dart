import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../repositories/groups_repository.dart';
import 'group_membership_entity.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit({required GroupsRepository repository})
      : _repository = repository,
        super(const GroupsState()) {
    _subscription = _repository.watchMyGroups().listen(
      (memberships) {
        _allMemberships = memberships;
        _updateStateWithFilteredAndSortedMemberships();
      },
      onError: (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'No pudimos cargar tus grupos. Intenta más tarde.',
          ),
        );
      },
    );
  }

  final GroupsRepository _repository;
  late final StreamSubscription _subscription;
  List<GroupMembershipEntity> _allMemberships = [];

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  void setQuery(String query) {
    if (query == state.query) return;
    _updateStateWithFilteredAndSortedMemberships(query: query);
  }

  Future<void> refresh() async {
    // The stream from watchMyGroups should automatically provide updates.
    // If a manual refresh is needed, we could re-fetch or trigger the stream again.
    // For now, let's just indicate loading.
    emit(state.copyWith(isLoading: true));
    try {
      // This is a bit of a hack. The repository should expose a refresh method.
      // The stream should be enough, but if not, we might need to add a method
      // to the repository to force a refresh.
      // For now, we just rely on the stream listening.
      _updateStateWithFilteredAndSortedMemberships();
    } finally {
       emit(state.copyWith(isLoading: false));
    }
  }

  void _updateStateWithFilteredAndSortedMemberships({String? query}) {
    final currentQuery = query ?? state.query;
    final filtered = _filterGroups(_allMemberships, currentQuery);
    final sorted = _sortGroups(filtered);
    emit(state.copyWith(
      memberships: sorted,
      totalMemberships: _allMemberships.length,
      query: currentQuery,
      errorMessage: null,
      isLoading: false,
    ));
  }

  List<GroupMembershipEntity> _filterGroups(
    List<GroupMembershipEntity> groups,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return List<GroupMembershipEntity>.from(groups);
    return groups
        .where((group) => group.groupName.toLowerCase().contains(trimmed))
        .toList();
  }

  List<GroupMembershipEntity> _sortGroups(List<GroupMembershipEntity> groups) {
    final sorted = List<GroupMembershipEntity>.from(groups);
    sorted.sort(_compareGroups);
    return sorted;
  }

  int _compareGroups(GroupMembershipEntity a, GroupMembershipEntity b) {
    final ap = _rolePriority(a.role);
    final bp = _rolePriority(b.role);
    if (ap != bp) return ap.compareTo(bp);
    return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
  }

  int _rolePriority(String role) {
    switch (role) {
      case 'owner':
        return 0;
      case 'admin':
        return 1;
      default:
        return 2;
    }
  }
}
