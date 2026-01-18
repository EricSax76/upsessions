import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../widgets/group_detail/group_page_view.dart';
import '../controllers/group_page_controller.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: DefaultTabController(
        length: 2,
        child: GroupPageView(
          groupId: groupId,
          controller: GroupPageController(),
        ),
      ),
    );
  }
}
