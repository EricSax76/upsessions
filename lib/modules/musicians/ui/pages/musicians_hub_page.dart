import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import 'musician_search_page.dart';

class MusiciansHubPage extends StatelessWidget {
  const MusiciansHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: MusicianSearchPage(showAppBar: false));
  }
}
