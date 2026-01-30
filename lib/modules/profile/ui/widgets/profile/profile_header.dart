import 'package:flutter/material.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SmAvatar(
          radius: 36,
          imageUrl: profile.photoUrl,
          fallbackIcon: Icons.person,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
            Text(profile.location),
          ],
        ),
      ],
    );
  }
}
