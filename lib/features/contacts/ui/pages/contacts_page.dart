import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';

import '../widgets/contacts_view.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: ContactsView());
  }
}
