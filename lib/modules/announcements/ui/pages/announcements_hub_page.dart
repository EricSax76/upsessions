import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import 'announcements_list_page.dart';

class AnnouncementsHubPage extends StatelessWidget {
  const AnnouncementsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: AnnouncementsListPage(showAppBar: false));
  }
}
