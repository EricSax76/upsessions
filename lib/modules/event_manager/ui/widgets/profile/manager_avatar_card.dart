import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';

class ManagerAvatarCard extends StatelessWidget {
  const ManagerAvatarCard({
    super.key,
    required this.initials,
    required this.isBusy,
    required this.onChangeTap,
    this.pendingPhotoBytes,
    this.imageUrl,
  });

  final String initials;
  final bool isBusy;
  final VoidCallback onChangeTap;
  final Uint8List? pendingPhotoBytes;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _avatar(context),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      onPressed: isBusy ? null : onChangeTap,
                      icon: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'Cambiar foto',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Foto del perfil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Sube una imagen y guarda para aplicar cambios.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    if (pendingPhotoBytes != null) {
      return ClipOval(
        child: Image.memory(
          pendingPhotoBytes!,
          width: 104,
          height: 104,
          fit: BoxFit.cover,
        ),
      );
    }
    return SmAvatar(
      radius: 52,
      imageUrl: imageUrl,
      initials: initials,
      fallbackIcon: Icons.store_outlined,
    );
  }
}
