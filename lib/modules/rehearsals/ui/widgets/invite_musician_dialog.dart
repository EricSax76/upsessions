import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../musicians/models/musician_entity.dart';
import '../pages/group_rehearsals_controller.dart';

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
                        if (i < _results.length - 1) const Divider(height: 1),
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
