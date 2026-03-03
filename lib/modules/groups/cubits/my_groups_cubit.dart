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
    String? description,
    String? city,
    String? province,
    String? sgaeGroupCode,
    Uint8List? photoBytes,
    String? photoFileExtension,
  }) async {
    return _groupsRepository.createGroup(
      name: name,
      genre: genre,
      link1: link1,
      link2: link2,
      description: description,
      city: city,
      province: province,
      sgaeGroupCode: sgaeGroupCode,
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
