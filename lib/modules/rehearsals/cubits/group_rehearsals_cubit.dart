import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../groups/models/group_dtos.dart';
import '../controllers/group_rehearsals_controller.dart';
import '../models/rehearsal_entity.dart';
import 'group_rehearsals_state.dart';

class GroupRehearsalsCubit extends Cubit<GroupRehearsalsState> {
  GroupRehearsalsCubit({
    required this.groupId,
    required GroupRehearsalsController controller,
  })  : _controller = controller,
        super(GroupRehearsalsLoading()) {
    _subscribe();
  }

  final String groupId;
  final GroupRehearsalsController _controller;

  final List<StreamSubscription> _subscriptions = [];
  GroupDoc? _group;
  String? _role;
  List<RehearsalEntity>? _rehearsals;
  bool _groupLoaded = false;
  bool _roleLoaded = false;
  bool _rehearsalsLoaded = false;

  void _subscribe() {
    _subscriptions.add(
      _controller.watchGroup(groupId).listen(
        (group) {
          _group = group;
          _groupLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      _controller.watchMyRole(groupId).listen(
        (role) {
          _role = role ?? '';
          _roleLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );

    _subscriptions.add(
      _controller.watchRehearsals(groupId).listen(
        (rehearsals) {
          _rehearsals = rehearsals;
          _rehearsalsLoaded = true;
          _emitIfReady();
        },
        onError: _handleError,
      ),
    );
  }

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
