import 'package:flutter/material.dart';

import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/sm_avatar.dart';
import '../../../models/group_dtos.dart';
import '../../../controllers/group_page_controller.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({super.key, required this.group, required this.controller});

  final GroupDoc group;
  final GroupPageController controller;

  Future<void> _handlePhotoTap(BuildContext context) async {
    try {
      final image = await controller.pickGroupPhoto(context);
      if (image == null) return;

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subiendo imagen...')));

      await controller.uploadGroupPhoto(groupId: group.id, image: image);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto del grupo actualizada')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              SmAvatar(
                radius: 45,
                imageUrl: group.photoUrl,
                fallbackIcon: Icons.group,
                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                foregroundColor: colorScheme.onPrimary,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _handlePhotoTap(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const VSpace(16),
          Text(
            group.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (group.genre.isNotEmpty) ...[
            const VSpace(4),
            Text(
              group.genre,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
