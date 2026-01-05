import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../controllers/liked_musicians_controller.dart';
import '../widgets/contacts_view.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = locate<LikedMusiciansController>();
    return UserShellPage(child: ContactsView(controller: controller));
  }
}
