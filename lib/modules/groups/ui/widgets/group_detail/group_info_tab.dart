import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_title.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/locator/locator.dart';
import '../../../../auth/cubits/auth_cubit.dart';
import '../../../models/group_dtos.dart';
import '../../../repositories/groups_repository.dart';

class GroupInfoTab extends StatelessWidget {
  const GroupInfoTab({super.key, required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthCubit cubit) => cubit.state.user?.id);
    final isOwner = userId != null && userId == group.ownerId;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (group.link1.isNotEmpty || group.link2.isNotEmpty) ...[
          const SectionTitle(text: 'Enlaces y Redes'),
          const VSpace(12),
          if (group.link1.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link1),
          if (group.link2.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link2),
          const VSpace(24),
        ],
        const SectionTitle(text: 'Configuración'),
        const VSpace(12),
        InfoTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'ID del grupo: ${group.id}',
        ),
        if (isOwner) ...[
          const VSpace(24),
          const SectionTitle(text: 'Acciones'),
          const VSpace(12),
          AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(0),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Eliminar grupo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              subtitle: const Text('Esta acci\u00f3n no se puede deshacer.'),
              onTap: () => _confirmDeleteGroup(context, group.id),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDeleteGroup(BuildContext context, String groupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: const Text(
          'Se eliminar\u00e1 el grupo y su informaci\u00f3n asociada. \u00bfContinuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = locate<GroupsRepository>();
    try {
      await repository.deleteGroup(groupId: groupId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo eliminado.')),
      );
      context.go(AppRoutes.rehearsals);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el grupo: $error')),
      );
    }
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
