import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  const SetlistHeader({super.key, required this.count, this.onAddSong});

  final int count;
  final VoidCallback? onAddSong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = Text('$count canciones');

    return LayoutBuilder(
      builder: (context, constraints) {
        final onAddSong = this.onAddSong;
        final hasAction = onAddSong != null;
        final isCompact = constraints.maxWidth < 420;

        final title = Text('Setlist', style: theme.textTheme.titleLarge);

        if (!hasAction) {
          return Row(
            children: [title, const Spacer(), countLabel],
          );
        }

        final addButton = FilledButton.icon(
          onPressed: onAddSong,
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar canción'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [title, const Spacer(), countLabel]),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: addButton),
            ],
          );
        }

        return Row(
          children: [
            title,
            const Spacer(),
            countLabel,
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }
}

class SetlistItemCard extends StatelessWidget {
  const SetlistItemCard({
    super.key,
    required this.item,
    required this.subtitle,
    required this.onDelete,
    this.onTap,
  });

  final SetlistItemEntity item;
  final Widget? subtitle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
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
    required this.linkUrl,
    required this.sheetBytes,
    required this.sheetFileExtension,
    required this.removeSheet,
  });

  final int order;
  final String songTitle;
  final String keySignature;
  final int? tempoBpm;
  final String notes;
  final String linkUrl;
  final Uint8List? sheetBytes;
  final String? sheetFileExtension;
  final bool removeSheet;
}

class SetlistItemDialog extends StatefulWidget {
  const SetlistItemDialog({
    super.key,
    required this.initialOrder,
    this.dialogTitle = 'Agregar canción',
    this.submitLabel = 'Agregar',
    this.initialTitle = '',
    this.initialKeySignature = '',
    this.initialTempoBpm,
    this.initialNotes = '',
    this.initialLinkUrl = '',
    this.initialSheetUrl = '',
  });

  final int initialOrder;
  final String dialogTitle;
  final String submitLabel;
  final String initialTitle;
  final String initialKeySignature;
  final int? initialTempoBpm;
  final String initialNotes;
  final String initialLinkUrl;
  final String initialSheetUrl;

  @override
  State<SetlistItemDialog> createState() => _SetlistItemDialogState();
}

class _SetlistItemDialogState extends State<SetlistItemDialog> {
  late final TextEditingController _title;
  late final TextEditingController _key;
  late final TextEditingController _tempo;
  late final TextEditingController _notes;
  late final TextEditingController _order;
  late final TextEditingController _link;

  Uint8List? _sheetBytes;
  String? _sheetFileExtension;
  bool _removeSheet = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle);
    _key = TextEditingController(text: widget.initialKeySignature);
    _tempo = TextEditingController(
      text: widget.initialTempoBpm?.toString() ?? '',
    );
    _notes = TextEditingController(text: widget.initialNotes);
    _order = TextEditingController(text: widget.initialOrder.toString());
    _link = TextEditingController(text: widget.initialLinkUrl);
  }

  @override
  void dispose() {
    _title.dispose();
    _key.dispose();
    _tempo.dispose();
    _notes.dispose();
    _order.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInitialSheet = widget.initialSheetUrl.trim().isNotEmpty;
    final hasSelection =
        _sheetBytes != null || (hasInitialSheet && !_removeSheet);

    return AlertDialog(
      title: Text(widget.dialogTitle),
      scrollable: true,
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
            const SizedBox(height: 12),
            TextField(
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Enlace (YouTube, etc.)',
                hintText: 'https://…',
              ),
            ),
            const SizedBox(height: 12),
            _SheetPickerRow(
              hasSelection: hasSelection,
              onPick: () => _pickSheetImage(context),
              onClear: () => setState(() {
                _sheetBytes = null;
                _sheetFileExtension = null;
                _removeSheet = true;
              }),
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
                linkUrl: _link.text.trim(),
                sheetBytes: _sheetBytes,
                sheetFileExtension: _sheetFileExtension,
                removeSheet: _removeSheet,
              ),
            );
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  Future<void> _pickSheetImage(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _sheetBytes = bytes;
      _sheetFileExtension = _extensionFromName(file.name);
      _removeSheet = false;
    });
  }
}

class _SheetPickerRow extends StatelessWidget {
  const _SheetPickerRow({
    required this.hasSelection,
    required this.onPick,
    required this.onClear,
  });

  final bool hasSelection;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(hasSelection ? 'Partitura seleccionada' : 'Subir partitura'),
          ),
        ),
        if (hasSelection) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Quitar',
            onPressed: onClear,
            icon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }
}

String? _extensionFromName(String name) {
  final dot = name.lastIndexOf('.');
  if (dot == -1) return null;
  final ext = name.substring(dot + 1).trim().toLowerCase();
  return ext.isEmpty ? null : ext;
}

String _formatDateTime(DateTime value) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} ${two(value.hour)}:${two(value.minute)}';
}
