import 'package:flutter/material.dart';
import 'profile_basic_info_fields.dart';
import 'profile_affinity_section.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileBasicInfoFields(),
          const SizedBox(height: 24),
          const ProfileAffinitySection(),
        ],
      ),
    );
  }
}
