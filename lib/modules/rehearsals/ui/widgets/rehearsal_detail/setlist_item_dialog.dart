import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      title: Row(
        children: [
          Icon(
            Icons.music_note_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(widget.dialogTitle),
        ],
      ),
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
            label: Text(
              hasSelection ? 'Partitura seleccionada' : 'Subir partitura',
            ),
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
