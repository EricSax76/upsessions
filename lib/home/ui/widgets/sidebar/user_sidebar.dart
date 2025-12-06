import 'package:flutter/material.dart';

import 'user_menu_list.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const UserMenuList(),
        ],
      ),
    );
  }
}
