import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../../logic/liked_musicians_controller.dart';
import '../widgets/contacts_view.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key, required this.controller});

  final LikedMusiciansController controller;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(child: ContactsView(controller: controller));
  }
}
