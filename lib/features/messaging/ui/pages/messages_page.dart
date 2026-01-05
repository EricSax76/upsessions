import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import 'chat_page.dart';

class MessagesPageArgs {
  const MessagesPageArgs({this.initialThreadId});

  final String? initialThreadId;
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key, this.initialThreadId});

  final String? initialThreadId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: ChatPage(
        showAppBar: false,
        initialThreadId: initialThreadId,
      ),
    );
  }
}
