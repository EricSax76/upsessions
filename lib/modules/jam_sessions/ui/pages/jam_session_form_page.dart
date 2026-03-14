import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../event_manager/cubits/event_manager_auth_cubit.dart';
import '../../../venues/cubits/venues_catalog_cubit.dart';
import '../../../venues/cubits/venues_catalog_state.dart';
import '../../../venues/models/venue_entity.dart';
import '../../cubits/jam_session_form_cubit.dart';
import '../../cubits/jam_session_form_state.dart';
import '../controllers/jam_session_form_controller.dart';
import '../widgets/form/jam_session_form_fields.dart';

class JamSessionFormPage extends StatefulWidget {
  const JamSessionFormPage({super.key});

  @override
  State<JamSessionFormPage> createState() => _JamSessionFormPageState();
}

class _JamSessionFormPageState extends State<JamSessionFormPage> {
  final _controller = JamSessionFormController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isPublic = true;
  bool _useRegisteredVenue = true;
  String? _selectedVenueId;

  @override
  void initState() {
    super.initState();
    final venuesState = context.read<VenuesCatalogCubit>().state;
    _syncVenueSelectionWithState(venuesState);
    if (!venuesState.isLoading &&
        venuesState.venues.isEmpty &&
        venuesState.errorMessage == null) {
      context.read<VenuesCatalogCubit>().loadSelectableVenues();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncVenueSelectionWithState(VenuesCatalogState state) {
    if (state.venues.isEmpty) {
      if (_useRegisteredVenue || _selectedVenueId != null) {
        _useRegisteredVenue = false;
        _selectedVenueId = null;
      }
      return;
    }
    final selected = _findSelectedVenue(state.venues);
    if (selected != null) return;
    _selectedVenueId = state.venues.first.id;
    _controller.applyVenueSelection(state.venues.first);
  }

  VenueEntity? _findSelectedVenue(List<VenueEntity> venues) {
    final selectedId = (_selectedVenueId ?? '').trim();
    if (selectedId.isEmpty) return null;
    for (final venue in venues) {
      if (venue.id == selectedId) return venue;
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveSession(List<VenueEntity> venues) {
    if (!_controller.formKey.currentState!.validate()) return;

    final managerId =
        context.read<EventManagerAuthCubit>().state.manager?.id ?? '';
    if (managerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesion como manager.')),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fecha y hora de la jam session.'),
        ),
      );
      return;
    }

    final requirements = _controller.parseRequirements(
      _controller.requirementsController.text,
    );
    if (requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anade al menos un instrumento o perfil requerido.'),
        ),
      );
      return;
    }

    final selectedVenue = _useRegisteredVenue ? _findSelectedVenue(venues) : null;
    if (_useRegisteredVenue && selectedVenue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un local registrado.')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    context.read<JamSessionFormCubit>().saveSession(
      _controller.buildSession(
        ownerId: managerId,
        dateTime: dateTime,
        selectedTime: _selectedTime!,
        isPublic: _isPublic,
        useRegisteredVenue: _useRegisteredVenue,
        selectedVenue: selectedVenue,
      ),
    );
  }

  void _onToggleUseRegisteredVenue(bool value, List<VenueEntity> venues) {
    setState(() {
      _useRegisteredVenue = value;
      if (_useRegisteredVenue && venues.isNotEmpty) {
        _selectedVenueId = _selectedVenueId ?? venues.first.id;
        final selected = _findSelectedVenue(venues);
        if (selected != null) _controller.applyVenueSelection(selected);
      }
    });
  }

  void _onVenueSelected(String? value, List<VenueEntity> venues) {
    setState(() {
      _selectedVenueId = value;
      final selected = _findSelectedVenue(venues);
      if (selected != null) _controller.applyVenueSelection(selected);
    });
  }

  void _onVenueStateChanged(BuildContext context, VenuesCatalogState state) {
    final wasUsingRegistered = _useRegisteredVenue;
    final previousSelectedId = _selectedVenueId;
    _syncVenueSelectionWithState(state);
    if (wasUsingRegistered != _useRegisteredVenue ||
        previousSelectedId != _selectedVenueId) {
      setState(() {});
    }
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

    return MultiBlocListener(
      listeners: [
        BlocListener<JamSessionFormCubit, JamSessionFormState>(
          listenWhen: (previous, current) =>
              previous.success != current.success ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jam session guardada exitosamente.'),
                ),
              );
              context.pop();
              return;
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
        ),
        BlocListener<VenuesCatalogCubit, VenuesCatalogState>(
          listener: _onVenueStateChanged,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva Jam Session')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: BlocBuilder<JamSessionFormCubit, JamSessionFormState>(
                builder: (context, formState) {
                  return BlocBuilder<VenuesCatalogCubit, VenuesCatalogState>(
                    builder: (context, venuesState) {
                      final venues = venuesState.venues;
                      return JamSessionFormFields(
                        controller: _controller,
                        isSaving: formState.isSaving,
                        formError: formState.errorMessage,
                        venues: venues,
                        isLoadingVenues: venuesState.isLoading,
                        venuesError: venuesState.errorMessage,
                        dateLabel: dateLabel,
                        timeLabel: timeLabel,
                        isPublic: _isPublic,
                        useRegisteredVenue: _useRegisteredVenue,
                        selectedVenueId: _selectedVenueId,
                        locationReadOnly: _useRegisteredVenue && venues.isNotEmpty,
                        onPickDate: _pickDate,
                        onPickTime: _pickTime,
                        onIsPublicChanged: (v) =>
                            setState(() => _isPublic = v),
                        onToggleUseRegisteredVenue: (value) =>
                            _onToggleUseRegisteredVenue(value, venues),
                        onVenueSelected: (value) =>
                            _onVenueSelected(value, venues),
                        onRetryLoadVenues: () => context
                            .read<VenuesCatalogCubit>()
                            .loadSelectableVenues(refresh: true),
                        onSave: () => _saveSession(venues),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
