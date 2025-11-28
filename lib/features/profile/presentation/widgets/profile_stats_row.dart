import 'package:flutter/material.dart';

import 'package:upsessions/features/auth/domain/profile_entity.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: profile.skills.map((skill) => Chip(label: Text(skill))).toList(),
    );
  }
}
