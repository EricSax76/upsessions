import 'package:flutter/material.dart';

import '../../../core/widgets/sm_avatar.dart';

class AccountProfileHeaderCard extends StatelessWidget {
  const AccountProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.uploadingPhoto,
    required this.onChangePhoto,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SmAvatar(
                  radius: 48,
                  imageUrl: avatarUrl,
                  fallbackIcon: Icons.person,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                if (uploadingPhoto)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: uploadingPhoto ? null : onChangePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Cambiar foto'),
            ),
          ],
        ),
      ),
    );
  }
}
