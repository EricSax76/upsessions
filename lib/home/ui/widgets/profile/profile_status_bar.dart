import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../modules/auth/cubits/auth_cubit.dart';
import '../../../../modules/auth/domain/profile_entity.dart';

class ProfileStatusBar extends StatelessWidget {
  const ProfileStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final profile = state.profile;
        final user = state.user;
        final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
        final displayName = profile?.name ?? user?.displayName ?? 'Tu perfil';
        final subtitle = _buildSubtitle(profile);

        return LayoutBuilder(
          builder: (context, constraints) {
            final avatar = CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            );
            final info = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            );
            final rowChildren = <Widget>[
              avatar,
              const SizedBox(width: 16),
              info,
            ];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Row(children: rowChildren)],
              ),
            );
          },
        );
      },
    );
  }

  String _buildSubtitle(ProfileEntity? profile) {
    if (profile == null) {
      return 'Completa tu perfil para destacar en la comunidad';
    }
    final role = profile.skills.isNotEmpty
        ? profile.skills.first
        : 'Talento disponible';
    final location = profile.location.isNotEmpty
        ? profile.location
        : 'Ubicación no registrada';
    if (profile.bio.isNotEmpty) {
      return profile.bio;
    }
    return '$role · $location';
  }
}
