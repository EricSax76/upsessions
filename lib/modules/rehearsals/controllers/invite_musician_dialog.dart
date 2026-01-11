import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';

import '../../musicians/models/musician_entity.dart';
import 'group_rehearsals_controller.dart';

class InviteMusicianDialog extends StatefulWidget {
  const InviteMusicianDialog({
    super.key,
    required this.groupId,
    required this.controller,
  });

  final String groupId;
  final GroupRehearsalsController controller;

  @override
  State<InviteMusicianDialog> createState() => _InviteMusicianDialogState();
}

class _InviteMusicianDialogState extends State<InviteMusicianDialog> {
  final _searchController = TextEditingController();

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add_alt_1_outlined,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Agregar músico'),
        ],
      ),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else if (_results.isEmpty)
              Text(
                'Sin resultados.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              SizedBox(
                height: 320,
                width: double.infinity,
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final target = _results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: scheme.surfaceContainerHighest,
                        foregroundColor: scheme.onSurface,
                        child: Text(
                          target.name.trim().isEmpty
                              ? '?'
                              : target.name
                                    .trim()
                                    .substring(0, 1)
                                    .toUpperCase(),
                        ),
                      ),
                      title: Text(
                        target.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        target.ownerId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.link,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () => _createInvite(context, target),
                    );
                  },
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
      final filtered = await widget.controller.searchInviteCandidates(
        query: trimmed,
      );
      if (!mounted) return;
      setState(() {
        _results = filtered;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _createInvite(
    BuildContext context,
    MusicianEntity target,
  ) async {
    try {
      final inviteId = await widget.controller.createInvite(
        groupId: widget.groupId,
        targetUid: target.ownerId,
      );
      final link =
          '$appLinkScheme:///invite?groupId=${widget.groupId}&inviteId=$inviteId';
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              const Text('Invitación creada'),
            ],
          ),
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
