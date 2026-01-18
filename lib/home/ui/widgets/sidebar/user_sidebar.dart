import 'package:flutter/material.dart';
import 'package:upsessions/home/ui/widgets/sidebar/language_selector.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'package:upsessions/modules/rehearsals/ui/widgets/rehearsals_sidebar_section.dart';
import 'user_menu_list.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.userSidebarTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const UserMenuList(),
          const SizedBox(height: 12),
          const RehearsalsSidebarSection(),
          const SizedBox(height: 12),
          const LanguageSelector(),
        ],
      ),
    );
  }
}
