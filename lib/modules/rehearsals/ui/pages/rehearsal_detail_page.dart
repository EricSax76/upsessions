import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../widgets/rehearsal_detail_view.dart';

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
      child: RehearsalDetailView(groupId: groupId, rehearsalId: rehearsalId),
    );
  }
}
