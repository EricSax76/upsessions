import 'package:flutter/material.dart';

import '../../../groups/repositories/groups_repository.dart';
import '../../../studios/repositories/studios_repository.dart';
import '../../repositories/rehearsals_repository.dart';
import '../../repositories/setlist_repository.dart';
import 'rehearsal_detail_view.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class RehearsalDetailPage extends StatelessWidget {
  const RehearsalDetailPage({
    super.key,
    required this.groupId,
    required this.rehearsalId,
  });

  final String groupId;
  final String rehearsalId;

  @override
  Widget build(BuildContext context) {
    return RehearsalDetailView(
      groupId: groupId,
      rehearsalId: rehearsalId,
      groupsRepository: context.read<GroupsRepository>(),
      rehearsalsRepository: context.read<RehearsalsRepository>(),
      setlistRepository: context.read<SetlistRepository>(),
      studiosRepository: context.read<StudiosRepository>(),
    );
  }
}
