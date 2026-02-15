import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import '../repositories/groups_repository.dart';
import 'my_groups_state.dart';

class MyGroupsCubit extends Cubit<MyGroupsState> {
  MyGroupsCubit({
    required GroupsRepository groupsRepository,
  })  : _groupsRepository = groupsRepository,
        super(const MyGroupsInitial()) {
    _start();
  }

  final GroupsRepository _groupsRepository;
  StreamSubscription? _groupsSubscription;

  void _start() {
    emit(const MyGroupsLoading());
    _groupsSubscription = _groupsRepository.watchMyGroups().listen(
      (groups) {
        emit(MyGroupsLoaded(groups));
      },
      onError: (error) {
        emit(MyGroupsError(error.toString()));
      },
    );
  }

  Future<String> createGroup({
    required String name,
    required String genre,
    String? link1,
    String? link2,
    Uint8List? photoBytes,
    String? photoFileExtension,
  }) async {
    // Note: The repository call will update the stream, so we don't need to manually emit UserGroupsLoaded here 
    // unless we want to handle optimistic updates or loading states for creation specifically.
    // For now, we just return the result or throw, letting the UI handle the navigation/error feedback 
    // while the stream updates the list.
    return _groupsRepository.createGroup(
      name: name,
      genre: genre,
      link1: link1,
      link2: link2,
      photoBytes: photoBytes,
      photoFileExtension: photoFileExtension,
    );
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
