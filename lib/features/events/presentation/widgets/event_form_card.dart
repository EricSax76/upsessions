import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';
import '../../domain/event_entity.dart';
import 'event_form/contact_section.dart';
import 'event_form/general_info_section.dart';
import 'event_form/location_calendar_section.dart';
import 'event_form/logistics_section.dart';

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
          GeneralInfoSection(
            titleController: _titleController,
            descriptionController: _descriptionController,
            tagsController: _tagsController,
          ),
          const VSpace(16),
          LocationCalendarSection(
            cityController: _cityController,
            venueController: _venueController,
            dateLabel: dateLabel,
            startLabel: startLabel,
            endLabel: endLabel,
            onPickDate: _pickDate,
            onPickStartTime: () => _pickTime(start: true),
            onPickEndTime: () => _pickTime(start: false),
          ),
          const VSpace(16),
          LogisticsSection(
            lineupController: _lineupController,
            resourcesController: _resourcesController,
            ticketController: _ticketController,
            capacityController: _capacityController,
          ),
          const VSpace(16),
          ContactSection(
            organizerController: _organizerController,
            contactEmailController: _contactEmailController,
            contactPhoneController: _contactPhoneController,
            notesController: _notesController,
          ),
          const VSpace(24),
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
          const VSpace(48),
        ],
      ),
    );
  }
}
