import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/profile/models/account_settings_card.dart';

import '../../cubits/account_preferences_cubit.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountPreferencesCubit(),
      child: const _AccountSettingsPageView(),
    );
  }
}

class _AccountSettingsPageView extends StatefulWidget {
  const _AccountSettingsPageView();

  @override
  State<_AccountSettingsPageView> createState() => _AccountSettingsPageViewState();
}

class _AccountSettingsPageViewState extends State<_AccountSettingsPageView> {
  late final GroupsRepository _groupsRepository;
  late final Stream<List<GroupMembershipEntity>> _myGroupsStream;
  final Set<String> _deletingGroupIds = <String>{};

  @override
  void initState() {
    super.initState();
    _groupsRepository = context.read<GroupsRepository>();
    _myGroupsStream = _groupsRepository.watchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ajustes de la cuenta', style: titleStyle),
            const SizedBox(height: 8),
            Text(
              'Configura tus preferencias de seguridad y comunicaciones.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  BlocBuilder<AccountPreferencesCubit, AccountPreferencesState>(
                    builder: (context, state) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AccountSettingsCard(
                              twoFactor: state.twoFactorEnabled,
                              newsletter: state.newsletterEnabled,
                              onTwoFactorChanged: context
                                  .read<AccountPreferencesCubit>()
                                  .toggleTwoFactor,
                              onNewsletterChanged: context
                                  .read<AccountPreferencesCubit>()
                                  .toggleNewsletter,
                            ),
                            const SizedBox(height: 24),
                            const _CenteredSectionTitle(text: 'Acciones'),
                            const SizedBox(height: 12),
                            StreamBuilder<List<GroupMembershipEntity>>(
                              stream: _myGroupsStream,
                              builder: _buildOwnerGroupActions,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerGroupActions(
    BuildContext context,
    AsyncSnapshot<List<GroupMembershipEntity>> snapshot,
  ) {
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

    final ownerGroups = snapshot.data!
        .where((group) => group.role == 'owner')
        .toList()
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
      children: ownerGroups.map((group) {
        final isDeleting = _deletingGroupIds.contains(group.groupId);
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
            onTap: isDeleting ? null : () => _confirmDeleteGroup(group),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _confirmDeleteGroup(GroupMembershipEntity group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          'Se eliminará "${group.groupName}" y su información asociada. '
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingGroupIds.add(group.groupId);
    });

    try {
      await _groupsRepository.deleteGroup(groupId: group.groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grupo "${group.groupName}" eliminado.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el grupo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingGroupIds.remove(group.groupId);
        });
      }
    }
  }
}

class _CenteredSectionTitle extends StatelessWidget {
  const _CenteredSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
