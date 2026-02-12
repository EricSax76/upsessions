import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

import '../../../models/musician_entity.dart';

class InviteToGroupDialog extends StatefulWidget {
  const InviteToGroupDialog({
    super.key,
    required this.target,
    required this.targetUid,
    required this.groupsRepository,
  });

  final MusicianEntity target;
  final String targetUid;
  final GroupsRepository groupsRepository;

  @override
  State<InviteToGroupDialog> createState() => _InviteToGroupDialogState();
}

class _InviteToGroupDialogState extends State<InviteToGroupDialog> {
  bool _loading = false;
  late final Stream<List<GroupMembershipEntity>> _myGroupsStream;

  @override
  void initState() {
    super.initState();
    _myGroupsStream = widget.groupsRepository.watchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final dialogWidth = math.min(
      520.0,
      math.max(280.0, MediaQuery.sizeOf(context).width - 96),
    );
    return AlertDialog(
      title: const Text('Invitar a un grupo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para: ${widget.target.name}'),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              StreamBuilder<List<GroupMembershipEntity>>(
                stream: _myGroupsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'No se pudieron cargar tus grupos: ${snapshot.error}',
                      style: TextStyle(color: colors.error),
                    );
                  }
                  final groups =
                      (snapshot.data ?? const <GroupMembershipEntity>[])
                          .where((g) => g.role == 'owner' || g.role == 'admin')
                          .toList();
                  if (groups.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No tienes grupos donde puedas invitar.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            GoRouter.of(context).go(AppRoutes.rehearsals);
                          },
                          icon: const Icon(Icons.group_add_outlined),
                          label: Text(loc.rehearsalsSidebarCreateGroupTitle),
                        ),
                      ],
                    );
                  }
                  return SizedBox(
                    width: dialogWidth,
                    height: 280,
                    child: ListView.separated(
                      itemCount: groups.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return ListTile(
                          leading: const Icon(Icons.groups_outlined),
                          title: Text(group.groupName),
                          subtitle: Text('Rol: ${group.role}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _loading
                              ? null
                              : () => _createInvite(context, group.groupId),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _createInvite(BuildContext context, String groupId) async {
    setState(() => _loading = true);
    try {
      final inviteId = await widget.groupsRepository.createInvite(
        groupId: groupId,
        targetUid: widget.targetUid,
      );
      final invitePath = AppRoutes.invitePath(
        groupId: groupId,
        inviteId: inviteId,
      );
      final link = '$appLinkScheme://$invitePath';
      if (!context.mounted) return;

      final dialogWidth = math.min(
        520.0,
        math.max(280.0, MediaQuery.sizeOf(context).width - 96),
      );
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invitación creada'),
          content: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Para: ${widget.target.name}'),
                const SizedBox(height: 12),
                SelectableText(link),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: link));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copiado.')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        GoRouter.of(context).go(invitePath);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Probar aquí'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Listo'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(this.context).pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la invitación: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
