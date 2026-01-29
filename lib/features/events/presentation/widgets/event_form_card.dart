import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';
import '../../domain/event_entity.dart';

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

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SectionCard(
            title: 'Información general',
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del evento',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value != null && value.trim().isNotEmpty
                      ? null
                      : 'Requerido',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.short_text),
                  ),
                  minLines: 3,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (separados por coma)',
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Calendario y ubicación',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Ciudad',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (value) =>
                            value != null && value.trim().isNotEmpty
                            ? null
                            : 'Requerido',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _venueController,
                        decoration: const InputDecoration(
                          labelText: 'Venue',
                          prefixIcon: Icon(Icons.place),
                        ),
                        validator: (value) =>
                            value != null && value.trim().isNotEmpty
                            ? null
                            : 'Requerido',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PickerField(
                  label: 'Fecha',
                  value: dateLabel,
                  onTap: _pickDate,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PickerField(
                        label: 'Inicio',
                        value: startLabel,
                        onTap: () => _pickTime(start: true),
                        icon: Icons.access_time,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PickerField(
                        label: 'Fin',
                        value: endLabel,
                        onTap: () => _pickTime(start: false),
                        icon: Icons.access_time_filled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Logística y detalles',
            child: Column(
              children: [
                TextFormField(
                  controller: _lineupController,
                  decoration: const InputDecoration(
                    labelText: 'Lineup (separado por coma)',
                    prefixIcon: Icon(Icons.group_work),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _resourcesController,
                  decoration: const InputDecoration(
                    labelText: 'Recursos/Backline',
                    prefixIcon: Icon(Icons.speaker),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ticketController,
                        decoration: const InputDecoration(
                          labelText: 'Entradas/Aporte',
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad',
                          prefixIcon: Icon(Icons.people),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Contacto',
            child: Column(
              children: [
                TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(
                    labelText: 'Organizador',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas adicionales',
                    prefixIcon: Icon(Icons.note),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar y crear ficha'),
            ),
          ),
          const SizedBox(height: 48), // Bottom padding
        ],
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
    this.icon,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        child: Text(value),
      ),
    );
  }
}
