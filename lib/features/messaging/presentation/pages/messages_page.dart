import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import 'chat_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: ChatPage(showAppBar: false));
  }
}
