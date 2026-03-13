import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../models/gig_offer_entity.dart';
import '../../../cubits/gig_offer_form_cubit.dart';
import '../../../cubits/gig_offer_form_state.dart';
import '../../../cubits/event_manager_auth_cubit.dart';

class GigOfferForm extends StatefulWidget {
  const GigOfferForm({super.key});

  @override
  State<GigOfferForm> createState() => _GigOfferFormState();
}

class _GigOfferFormState extends State<GigOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  List<String> _parseRequirements(String raw) {
    return raw
        .split(RegExp(r'[,\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _saveOffer() {
    if (!_formKey.currentState!.validate()) return;

    final managerId =
        context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
    if (managerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión como manager.')),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora del bolo.')),
      );
      return;
    }

    final requirements = _parseRequirements(_requirementsController.text);
    if (requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un instrumento o perfil requerido.'),
        ),
      );
      return;
    }

    final date = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final budget = _budgetController.text.trim();
    final offer = GigOfferEntity(
      id: '',
      managerId: managerId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      instrumentRequirements: requirements,
      date: date,
      time: _formatTime(_selectedTime!),
      location: _locationController.text.trim(),
      budget: budget.isEmpty ? null : budget,
      status: GigOfferStatus.open,
      applicants: const [],
      createdAt: DateTime.now(),
    );

    context.read<GigOfferFormCubit>().saveOffer(offer);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = _selectedDate == null
        ? 'Seleccionar fecha'
        : localizations.formatMediumDate(_selectedDate!);
    final timeLabel = _selectedTime == null
        ? 'Seleccionar hora'
        : localizations.formatTimeOfDay(_selectedTime!);

    return BlocConsumer<GigOfferFormCubit, GigOfferFormState>(
      listenWhen: (prev, curr) =>
          prev.success != curr.success ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oferta publicada exitosamente')),
          );
          context.pop();
          return;
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Nueva Oferta (Casting)')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: IgnorePointer(
                  ignoring: state.isSaving,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isSaving) const LinearProgressIndicator(),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título de la oferta',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del bolo',
                        ),
                        maxLines: 3,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _requirementsController,
                        decoration: const InputDecoration(
                          labelText: 'Instrumentos / perfiles requeridos',
                          hintText: 'Ej. Voz principal, Guitarra, Teclado',
                        ),
                        maxLines: 2,
                        validator: (val) =>
                            _parseRequirements(val ?? '').isEmpty
                            ? 'Añade al menos un perfil'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(dateLabel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(timeLabel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar / Ciudad',
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: const InputDecoration(
                          labelText: 'Presupuesto (opcional)',
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: state.isSaving ? null : _saveOffer,
                        child: Text(
                          state.isSaving ? 'Publicando...' : 'Publicar Oferta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
