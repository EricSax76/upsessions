import 'package:flutter/material.dart';

import 'rehearsal_helpers.dart';

class RehearsalDraft {
  const RehearsalDraft({
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

class RehearsalDialog extends StatefulWidget {
  const RehearsalDialog({super.key});

  @override
  State<RehearsalDialog> createState() => _RehearsalDialogState();
}

class _RehearsalDialogState extends State<RehearsalDialog> {
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
        : formatDateTime(_startsAt!);
    final endsLabel = _endsAt == null ? 'Opcional' : formatDateTime(_endsAt!);

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
                  RehearsalDraft(
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
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
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
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (_startsAt != null && selected.isBefore(_startsAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El fin no puede ser antes del inicio.')),
      );
      return;
    }
    setState(() => _endsAt = selected);
  }
}
