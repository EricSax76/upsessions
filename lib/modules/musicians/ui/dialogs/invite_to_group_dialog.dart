import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/cubits/invite_to_group_cubit.dart';

import '../../models/musician_entity.dart';

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
  late final Stream<List<GroupMembershipEntity>> _myGroupsStream;

  @override
  void initState() {
    super.initState();
    _myGroupsStream = widget.groupsRepository.watchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = math.min(
      520.0,
      math.max(280.0, MediaQuery.sizeOf(context).width - 96),
    );

    return BlocProvider(
      create: (context) =>
          InviteToGroupCubit(groupsRepository: widget.groupsRepository),
      child: BlocBuilder<InviteToGroupCubit, InviteToGroupState>(
        builder: (context, state) {
          final isLoading = state is InviteToGroupLoading;

          return AlertDialog(
            title: Text(
              state is InviteToGroupSuccess
                  ? 'Invitación creada'
                  : 'Invitar a un grupo',
            ),
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
                    if (isLoading) const LinearProgressIndicator(),
                    if (state is InviteToGroupError) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (state is InviteToGroupSuccess)
                      _InviteSuccessContent(success: state)
                    else
                      _AvailableGroupsList(
                        stream: _myGroupsStream,
                        loading: isLoading,
                        targetUid: widget.targetUid,
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              if (state is InviteToGroupSuccess)
                TextButton(
                  onPressed: () => context.read<InviteToGroupCubit>().reset(),
                  child: const Text('Crear otra'),
                ),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvailableGroupsList extends StatelessWidget {
  const _AvailableGroupsList({
    required this.stream,
    required this.loading,
    required this.targetUid,
  });

  final Stream<List<GroupMembershipEntity>> stream;
  final bool loading;
  final String targetUid;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<List<GroupMembershipEntity>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'No se pudieron cargar tus grupos: ${snapshot.error}',
            style: TextStyle(color: colors.error),
          );
        }

        final groups = (snapshot.data ?? const <GroupMembershipEntity>[])
            .where((group) => group.role == 'owner' || group.role == 'admin')
            .toList(growable: false);

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
          height: 280,
          child: ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(group.groupName),
                subtitle: Text('Rol: ${group.role}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: loading
                    ? null
                    : () => context.read<InviteToGroupCubit>().createInvite(
                        groupId: group.groupId,
                        targetUid: targetUid,
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

class _InviteSuccessContent extends StatelessWidget {
  const _InviteSuccessContent({required this.success});

  final InviteToGroupSuccess success;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(success.link),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: success.link));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Link copiado.')));
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar link'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                router.go(success.invitePath);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Probar aquí'),
            ),
          ],
        ),
      ],
    );
  }
}
