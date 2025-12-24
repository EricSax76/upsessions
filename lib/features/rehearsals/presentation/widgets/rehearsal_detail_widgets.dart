import 'package:flutter/material.dart';

import '../../domain/rehearsal_entity.dart';
import '../../domain/setlist_item_entity.dart';

class RehearsalInfoCard extends StatelessWidget {
  const RehearsalInfoCard({super.key, required this.rehearsal});

  final RehearsalEntity rehearsal;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(rehearsal.startsAt),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (rehearsal.endsAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Fin: ${_formatDateTime(rehearsal.endsAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            if (rehearsal.location.trim().isNotEmpty) ...[
              InfoRow(
                icon: Icons.place_outlined,
                text: rehearsal.location,
              ),
              const SizedBox(height: 8),
            ],
            if (rehearsal.notes.trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(rehearsal.notes),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class SetlistHeader extends StatelessWidget {
  const SetlistHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Setlist', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        Text('$count canciones'),
      ],
    );
  }
}

class SetlistItemCard extends StatelessWidget {
  const SetlistItemCard({
    super.key,
    required this.item,
    required this.subtitle,
    required this.onDelete,
  });

  final SetlistItemEntity item;
  final Widget? subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.order.toString(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodySmall ??
                          const TextStyle(),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class SetlistDraft {
  const SetlistDraft({
    required this.order,
    required this.songTitle,
    required this.keySignature,
    required this.tempoBpm,
    required this.notes,
  });

  final int order;
  final String songTitle;
  final String keySignature;
  final int? tempoBpm;
  final String notes;
}

class SetlistItemDialog extends StatefulWidget {
  const SetlistItemDialog({super.key, required this.initialOrder});

  final int initialOrder;

  @override
  State<SetlistItemDialog> createState() => _SetlistItemDialogState();
}

class _SetlistItemDialogState extends State<SetlistItemDialog> {
  late final TextEditingController _title;
  late final TextEditingController _key;
  late final TextEditingController _tempo;
  late final TextEditingController _notes;
  late final TextEditingController _order;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _key = TextEditingController();
    _tempo = TextEditingController();
    _notes = TextEditingController();
    _order = TextEditingController(text: widget.initialOrder.toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _key.dispose();
    _tempo.dispose();
    _notes.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar canción'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Canción',
                hintText: 'Ej. Autumn Leaves',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _key,
                    decoration: const InputDecoration(labelText: 'Tono'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tempo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tempo (bpm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _order,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Orden'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notas'),
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
          onPressed: () {
            final order =
                int.tryParse(_order.text.trim()) ?? widget.initialOrder;
            Navigator.of(context).pop(
              SetlistDraft(
                order: order,
                songTitle: _title.text.trim(),
                keySignature: _key.text.trim(),
                tempoBpm: int.tryParse(_tempo.text.trim()),
                notes: _notes.text.trim(),
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime value) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} ${two(value.hour)}:${two(value.minute)}';
}
