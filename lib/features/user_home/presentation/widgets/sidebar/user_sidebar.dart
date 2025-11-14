import 'package:flutter/material.dart';

import 'language_selector.dart';
import 'location_selector.dart';
import 'top_influences_list.dart';
import 'user_menu_list.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({
    super.key,
    required this.province,
    required this.city,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final String province;
  final String city;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

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
          const Divider(height: 32),
          LocationSelector(
            province: province,
            city: city,
            onProvinceChanged: onProvinceChanged,
            onCityChanged: onCityChanged,
          ),
          const SizedBox(height: 16),
          const LanguageSelector(),
          const SizedBox(height: 16),
          const TopInfluencesList(),
        ],
      ),
    );
  }
}
