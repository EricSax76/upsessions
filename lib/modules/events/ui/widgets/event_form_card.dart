import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';
import '../../models/event_entity.dart';
import 'event_form/compliance_section.dart';
import 'event_form/contact_section.dart';
import 'event_form/event_form_controllers.dart';
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
  final _controllers = EventFormControllers();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isPublic = true;
  bool _isFree = false;

  @override
  void dispose() {
    _controllers.dispose();
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
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start
          ? (_startTime ?? const TimeOfDay(hour: 19, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 22, minute: 0)),
    );
    if (picked != null) {
      setState(() => start ? _startTime = picked : _endTime = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final ownerId = widget.ownerId;
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para crear un evento.'),
        ),
      );
      return;
    }

    final event = _controllers.buildEvent(
      ownerId: ownerId,
      date: _selectedDate ?? DateTime.now().add(const Duration(days: 5)),
      startTime: _startTime ?? const TimeOfDay(hour: 19, minute: 0),
      endTime: _endTime ?? const TimeOfDay(hour: 22, minute: 0),
      isPublic: _isPublic,
      isFree: _isFree,
    );
    widget.onGenerateDraft(event);
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final dateLabel = _selectedDate == null
        ? 'Selecciona una fecha'
        : loc.formatMediumDate(_selectedDate!);
    final startLabel =
        _startTime == null ? 'Inicio' : loc.formatTimeOfDay(_startTime!);
    final endLabel =
        _endTime == null ? 'Fin' : loc.formatTimeOfDay(_endTime!);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          GeneralInfoSection(
            titleController: _controllers.title,
            descriptionController: _controllers.description,
            tagsController: _controllers.tags,
          ),
          const VSpace(16),
          LocationCalendarSection(
            cityController: _controllers.city,
            venueController: _controllers.venue,
            dateLabel: dateLabel,
            startLabel: startLabel,
            endLabel: endLabel,
            onPickDate: _pickDate,
            onPickStartTime: () => _pickTime(start: true),
            onPickEndTime: () => _pickTime(start: false),
          ),
          const VSpace(16),
          LogisticsSection(
            lineupController: _controllers.lineup,
            resourcesController: _controllers.resources,
            ticketController: _controllers.ticket,
            capacityController: _controllers.capacity,
          ),
          const VSpace(16),
          ContactSection(
            organizerController: _controllers.organizer,
            contactEmailController: _controllers.contactEmail,
            contactPhoneController: _controllers.contactPhone,
            notesController: _controllers.notes,
          ),
          const VSpace(16),
          ComplianceSection(
            provinceController: _controllers.province,
            postalCodeController: _controllers.postalCode,
            eventLicenseNumberController: _controllers.eventLicenseNumber,
            ticketPriceController: _controllers.ticketPrice,
            vatRateController: _controllers.vatRate,
            ageRestrictionController: _controllers.ageRestriction,
            accessibilityInfoController: _controllers.accessibilityInfo,
            cancellationPolicyController: _controllers.cancellationPolicy,
            isPublic: _isPublic,
            isFree: _isFree,
            onIsPublicChanged: (v) => setState(() => _isPublic = v),
            onIsFreeChanged: (v) => setState(() => _isFree = v),
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
