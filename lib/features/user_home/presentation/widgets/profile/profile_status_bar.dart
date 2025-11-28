import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../auth/application/auth_cubit.dart';
import '../../../../auth/domain/profile_entity.dart';

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
            final isCompact = constraints.maxWidth < 600;
            final avatar = CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary)
                  : null,
            );
            final info = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            );
            final editButton = FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profileEdit),
              icon: const Icon(Icons.edit),
              label: const Text('Actualizar perfil'),
            );
            final rowChildren = <Widget>[
              avatar,
              const SizedBox(width: 16),
              info,
              const SizedBox(width: 16),
              editButton,
            ];
            final actions = [
              _ProfileActionButton(
                icon: Icons.post_add_outlined,
                label: 'Nuevo anuncio',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.announcements),
              ),
              _ProfileActionButton(
                icon: Icons.campaign_outlined,
                label: 'Promocionar show',
                onPressed: () => _showSnack(context),
              ),
              _ProfileActionButton(
                icon: Icons.event_outlined,
                label: 'Agendar evento',
                onPressed: () => _showSnack(context),
              ),
            ];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: rowChildren.take(3).toList()),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: editButton),
                      ],
                    )
                  else
                    Row(children: rowChildren),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, runSpacing: 12, children: actions),
                ],
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
    final role = profile.skills.isNotEmpty ? profile.skills.first : 'Talento disponible';
    final location = profile.location.isNotEmpty ? profile.location : 'Ubicación no registrada';
    if (profile.bio.isNotEmpty) {
      return profile.bio;
    }
    return '$role · $location';
  }

  void _showSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')));
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
        shape: const StadiumBorder(),
      ),
    );
  }
}
