import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import 'package:upsessions/features/rehearsals/data/rehearsals_repository.dart';
import 'package:upsessions/features/rehearsals/application/create_rehearsal_use_case.dart';
import '../../../../modules/auth/data/auth_repository.dart';
import '../../../../modules/musicians/data/musicians_repository.dart';
import '../../../../modules/musicians/domain/musician_entity.dart';
import '../../data/groups_repository.dart';
import '../../domain/rehearsal_entity.dart';

class GroupRehearsalsPage extends StatelessWidget {
  const GroupRehearsalsPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(child: _GroupRehearsalsView(groupId: groupId));
  }
}

class _GroupRehearsalsView extends StatelessWidget {
  const _GroupRehearsalsView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final groupsRepository = locate<GroupsRepository>();
    final rehearsalsRepository = locate<RehearsalsRepository>();
    final createRehearsalUseCase = locate<CreateRehearsalUseCase>();

    return StreamBuilder<String>(
      stream: groupsRepository.watchGroupName(groupId),
      builder: (context, groupNameSnapshot) {
        final groupName = groupNameSnapshot.data ?? 'Grupo';
        return StreamBuilder<String?>(
          stream: groupsRepository.watchMyRole(groupId),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data ?? '';
            final canManageMembers = role == 'owner' || role == 'admin';
            return StreamBuilder<List<RehearsalEntity>>(
              stream: rehearsalsRepository.watchRehearsals(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final rehearsals = snapshot.data ?? const [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ensayos',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Crear ensayo',
                          onPressed: () =>
                              _createRehearsal(context, createRehearsalUseCase),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        IconButton(
                          tooltip: canManageMembers
                              ? 'Agregar músico'
                              : 'Solo owner/admin',
                          onPressed: canManageMembers
                              ? () => _openInviteDialog(context)
                              : null,
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (rehearsals.isEmpty)
                      const Text('Todavía no hay ensayos. Crea el primero.')
                    else
                      ...rehearsals.map(
                        (rehearsal) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.event_available_outlined),
                            title: Text(_formatDateTime(rehearsal.startsAt)),
                            subtitle: rehearsal.location.trim().isEmpty
                                ? null
                                : Text(rehearsal.location),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go(
                              AppRoutes.rehearsalDetail(
                                groupId: groupId,
                                rehearsalId: rehearsal.id,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createRehearsal(
    BuildContext context,
    CreateRehearsalUseCase createRehearsal,
  ) async {
    final result = await showDialog<_RehearsalDraft>(
      context: context,
      builder: (context) => _RehearsalDialog(),
    );
    if (result == null) return;
    try {
      final rehearsalId = await createRehearsal(
        groupId: groupId,
        startsAt: result.startsAt,
        endsAt: result.endsAt,
        location: result.location,
        notes: result.notes,
        ensureActiveMember: true,
      );
      if (!context.mounted) return;
      context.go(
        AppRoutes.rehearsalDetail(groupId: groupId, rehearsalId: rehearsalId),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el ensayo: $error')),
      );
    }
  }

  Future<void> _openInviteDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _InviteMusicianDialog(groupId: groupId),
    );
  }

  static String _formatDateTime(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _RehearsalDraft {
  const _RehearsalDraft({
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.notes,
  });

  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String notes;
}

class _RehearsalDialog extends StatefulWidget {
  @override
  State<_RehearsalDialog> createState() => _RehearsalDialogState();
}

class _RehearsalDialogState extends State<_RehearsalDialog> {
  DateTime? _startsAt;
  DateTime? _endsAt;
  final _location = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startsLabel = _startsAt == null
        ? 'Elegir fecha/hora'
        : _GroupRehearsalsView._formatDateTime(_startsAt!);
    final endsLabel = _endsAt == null
        ? 'Opcional'
        : _GroupRehearsalsView._formatDateTime(_endsAt!);

    return AlertDialog(
      title: const Text('Nuevo ensayo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Inicio'),
              subtitle: Text(startsLabel),
              onTap: () => _pickStartsAt(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Fin'),
              subtitle: Text(endsLabel),
              onTap: () => _pickEndsAt(context),
              trailing: _endsAt == null
                  ? null
                  : IconButton(
                      tooltip: 'Quitar fin',
                      onPressed: () => setState(() => _endsAt = null),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            TextField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'Lugar',
                hintText: 'Ej. Sala 2 / Estudio',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notas',
                hintText: 'Ej. Traer metrónomo',
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _startsAt == null
              ? null
              : () => Navigator.of(context).pop(
                    _RehearsalDraft(
                      startsAt: _startsAt!,
                      endsAt: _endsAt,
                      location: _location.text,
                      notes: _notes.text,
                    ),
                  ),
          child: const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _pickStartsAt(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _startsAt ?? now,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (time == null || !context.mounted) return;
    setState(() {
      _startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (_endsAt != null && _endsAt!.isBefore(_startsAt!)) {
        _endsAt = null;
      }
    });
  }

  Future<void> _pickEndsAt(BuildContext context) async {
    final base = _startsAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(base.year - 1),
      lastDate: DateTime(base.year + 5),
      initialDate: _endsAt ?? base,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endsAt ?? base),
    );
    if (time == null || !context.mounted) return;
    final selected =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (_startsAt != null && selected.isBefore(_startsAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El fin no puede ser antes del inicio.')),
      );
      return;
    }
    setState(() => _endsAt = selected);
  }
}

class _InviteMusicianDialog extends StatefulWidget {
  const _InviteMusicianDialog({required this.groupId});

  final String groupId;

  @override
  State<_InviteMusicianDialog> createState() => _InviteMusicianDialogState();
}

class _InviteMusicianDialogState extends State<_InviteMusicianDialog> {
  final _searchController = TextEditingController();
  final _musiciansRepository = locate<MusiciansRepository>();
  final _authRepository = locate<AuthRepository>();
  final _groupsRepository = locate<GroupsRepository>();

  String _query = '';
  bool _loading = false;
  List<MusicianEntity> _results = const [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar músico'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                hintText: 'Ej. ana',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _search(value),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              )
            else if (_query.trim().isEmpty)
              Text(
                'Escribe al menos 1 carácter.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else if (_results.isEmpty)
              Text(
                'Sin resultados.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              SizedBox(
                height: 320,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _results.length; i++) ...[
                        ListTile(
                          title: Text(_results[i].name),
                          subtitle: Text(_results[i].ownerId),
                          trailing: const Icon(Icons.link),
                          onTap: () => _createInvite(context, _results[i]),
                        ),
                        if (i < _results.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _search(String value) async {
    final trimmed = value.trim();
    setState(() {
      _query = trimmed;
      _loading = true;
    });
    try {
      final me = _authRepository.currentUser?.id;
      final results = await _musiciansRepository.search(query: trimmed);
      final filtered = results
          .where((musician) => musician.name.trim().isNotEmpty)
          .where((musician) => musician.ownerId.trim().isNotEmpty)
          .where((musician) => me == null || musician.ownerId != me)
          .toList();
      if (!mounted) return;
      setState(() {
        _results = filtered;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _createInvite(BuildContext context, MusicianEntity target) async {
    try {
      final inviteId = await _groupsRepository.createInvite(
        groupId: widget.groupId,
        targetUid: target.ownerId,
      );
      final link =
          'myapp:///invite?groupId=${widget.groupId}&inviteId=$inviteId';
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invitación creada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para: ${target.name}'),
              const SizedBox(height: 12),
              SelectableText(link),
              const SizedBox(height: 12),
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
            ],
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
    }
  }
}
