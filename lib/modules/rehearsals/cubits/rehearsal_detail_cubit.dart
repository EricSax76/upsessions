import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../groups/models/group_dtos.dart';
import '../../groups/repositories/groups_repository.dart';
import 'rehearsal_entity.dart';
import 'setlist_item_entity.dart';
import '../repositories/rehearsals_repository.dart';
import '../repositories/setlist_repository.dart';
import 'rehearsal_detail_state.dart';

class RehearsalDetailCubit extends Cubit<RehearsalDetailState> {
  RehearsalDetailCubit({
    required this.groupId,
    required this.rehearsalId,
    required this.userId,
    required this.groupsRepository,
    required this.rehearsalsRepository,
    required this.setlistRepository,
  }) : super(RehearsalDetailInitial()) {
    _subscribe();
  }

  final String groupId;
  final String rehearsalId;
  final String? userId;
  final GroupsRepository groupsRepository;
  final RehearsalsRepository rehearsalsRepository;
  final SetlistRepository setlistRepository;

  final List<StreamSubscription> _subscriptions = [];
  GroupDoc? _group;
  RehearsalEntity? _rehearsal;
  List<SetlistItemEntity>? _setlist;

  void _subscribe() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    emit(RehearsalDetailLoading());

    _subscriptions.add(
      groupsRepository.watchGroup(groupId).listen(
        (group) {
          _group = group;
          _updateState();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      rehearsalsRepository
          .watchRehearsal(groupId: groupId, rehearsalId: rehearsalId)
          .listen(
        (rehearsal) {
          _rehearsal = rehearsal;
          _updateState();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      setlistRepository
          .watchSetlist(groupId: groupId, rehearsalId: rehearsalId)
          .listen(
        (setlist) {
          _setlist = setlist;
          _updateState();
        },
        onError: _handleError,
      ),
    );
  }

  void _updateState() {
    final group = _group;
    final rehearsal = _rehearsal;
    final setlist = _setlist;

    if (group == null || rehearsal == null || setlist == null) {
      // Still loading or not found
      if (rehearsal == null && group != null && setlist != null) {
        emit(const RehearsalDetailNotFound('Ensayo no encontrado.'));
      }
      return;
    }

    final canDelete = userId != null && group.ownerId == userId;

    emit(RehearsalDetailLoaded(
      group: group,
      rehearsal: rehearsal,
      setlist: setlist,
      canDelete: canDelete,
    ));
  }

  void _handleError(Object error) {
    emit(RehearsalDetailError(error.toString()));
  }

  Future<void> reorderSetlist(List<String> itemIdsInOrder) async {
    try {
      await setlistRepository.setSetlistOrders(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemIdsInOrder: itemIdsInOrder,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> close() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
