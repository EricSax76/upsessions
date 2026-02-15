import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../core/locator/locator.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../../studios/repositories/studios_repository.dart';
import '../../repositories/rehearsals_repository.dart';
import '../../repositories/setlist_repository.dart';
import 'rehearsal_detail_view.dart';

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
    return UserShellPage(
      child: RehearsalDetailView(
        groupId: groupId,
        rehearsalId: rehearsalId,
        groupsRepository: locate<GroupsRepository>(),
        rehearsalsRepository: locate<RehearsalsRepository>(),
        setlistRepository: locate<SetlistRepository>(),
        studiosRepository: locate<StudiosRepository>(),
      ),
    );
  }
}
