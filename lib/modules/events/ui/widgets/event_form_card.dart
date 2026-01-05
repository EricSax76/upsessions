import 'package:flutter/material.dart';

import '../../models/event_entity.dart';

class EventFormCard extends StatefulWidget {
  const EventFormCard({
    super.key,
    required this.onGenerateDraft,
    required this.ownerId,
  });

  final ValueChanged<EventEntity> onGenerateDraft;
  final String? ownerId;

  @override
  State<EventFormCard> createState() => _EventFormCardState();
}

class _EventFormCardState extends State<EventFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: '');
  final _cityController = TextEditingController(text: '');
  final _venueController = TextEditingController(text: '');
  final _descriptionController = TextEditingController(text: '');
  final _organizerController = TextEditingController(text: '');
  final _contactEmailController = TextEditingController(text: '');
  final _contactPhoneController = TextEditingController(text: '');
  final _lineupController = TextEditingController(text: '');
  final _tagsController = TextEditingController(text: '');
  final _ticketController = TextEditingController(text: '');
  final _capacityController = TextEditingController(text: '');
  final _resourcesController = TextEditingController(text: '');
  final _notesController = TextEditingController(text: '');

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _lineupController.dispose();
    _tagsController.dispose();
    _ticketController.dispose();
    _capacityController.dispose();
    _resourcesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start
          ? (_startTime ?? const TimeOfDay(hour: 19, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 22, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final ownerId = widget.ownerId;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes iniciar sesión como músico para crear un evento.',
          ),
        ),
      );
      return;
    }

    final date = _selectedDate ?? DateTime.now().add(const Duration(days: 5));
    final startTime = _startTime ?? const TimeOfDay(hour: 19, minute: 0);
    final endTime = _endTime ?? const TimeOfDay(hour: 22, minute: 0);
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final event = EventEntity(
      id: '',
      ownerId: ownerId,
      title: _titleController.text.trim(),
      city: _cityController.text.trim(),
      venue: _venueController.text.trim(),
      start: startDateTime,
      end: endDateTime,
      description: _descriptionController.text.trim(),
      organizer: _organizerController.text.trim(),
      contactEmail: _contactEmailController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      lineup: _splitValues(_lineupController.text),
      tags: _splitValues(_tagsController.text),
      ticketInfo: _ticketController.text.trim(),
      capacity: capacity,
      resources: _splitValues(_resourcesController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    widget.onGenerateDraft(event);
  }

  List<String> _splitValues(String input) {
    return input
        .split(RegExp(r'[,\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final dateLabel = _selectedDate == null
        ? 'Selecciona una fecha'
        : loc.formatMediumDate(_selectedDate!);
    final startLabel = _startTime == null
        ? 'Inicio'
        : loc.formatTimeOfDay(_startTime!);
    final endLabel = _endTime == null ? 'Fin' : loc.formatTimeOfDay(_endTime!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del evento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value != null && value.trim().isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: (value) =>
                          value != null && value.trim().isNotEmpty
                          ? null
                          : 'Campo obligatorio',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'Lugar / venue',
                      ),
                      validator: (value) =>
                          value != null && value.trim().isNotEmpty
                          ? null
                          : 'Campo obligatorio',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PickerField(
                      label: 'Fecha',
                      value: dateLabel,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: PickerField(
                            label: 'Inicio',
                            value: startLabel,
                            onTap: () => _pickTime(start: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PickerField(
                            label: 'Fin',
                            value: endLabel,
                            onTap: () => _pickTime(start: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 3,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lineupController,
                decoration: const InputDecoration(
                  labelText: 'Lineup o dinámica (separado por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resourcesController,
                decoration: const InputDecoration(
                  labelText: 'Recursos/Backline (separado por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ticketController,
                decoration: const InputDecoration(
                  labelText: 'Entradas o aporte',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Organiza'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email de contacto',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separados por coma)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales (opcional)',
                ),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Generar ficha'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}
