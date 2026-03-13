import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';

typedef AsyncGroupActionCallback =
    Future<void> Function(GroupMembershipEntity group);

class OwnerGroupActionsSection extends StatelessWidget {
  const OwnerGroupActionsSection({
    required this.snapshot,
    required this.deletingGroupIds,
    required this.onDeleteGroupRequested,
    super.key,
  });

  final AsyncSnapshot<List<GroupMembershipEntity>> snapshot;
  final Set<String> deletingGroupIds;
  final AsyncGroupActionCallback onDeleteGroupRequested;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(0),
        child: const ListTile(
          leading: Icon(Icons.error_outline),
          title: Text('No se pudieron cargar tus grupos.'),
        ),
      );
    }

    if (!snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ownerGroups =
        snapshot.data!.where((group) => group.role == 'owner').toList()
          ..sort((a, b) => a.groupName.compareTo(b.groupName));

    if (ownerGroups.isEmpty) {
      return AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(0),
        child: const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('No tienes grupos para administrar.'),
        ),
      );
    }

    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Column(
      children: ownerGroups
          .map((group) {
            final isDeleting = deletingGroupIds.contains(group.groupId);
            return AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(0),
              child: ListTile(
                enabled: !isDeleting,
                leading: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.delete_outline, color: errorColor),
                title: Text(
                  group.groupName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Eliminar grupo (acción irreversible).'),
                onTap: isDeleting
                    ? null
                    : () {
                        unawaited(onDeleteGroupRequested(group));
                      },
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
