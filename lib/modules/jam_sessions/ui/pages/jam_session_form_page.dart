import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../event_manager/cubits/event_manager_auth_cubit.dart';
import '../../../venues/cubits/venues_catalog_cubit.dart';
import '../../../venues/cubits/venues_catalog_state.dart';
import '../../../venues/models/venue_entity.dart';
import '../../cubits/jam_session_form_cubit.dart';
import '../../cubits/jam_session_form_state.dart';
import '../controllers/jam_session_form_controller.dart';
import '../widgets/form/jam_session_compliance_section.dart';
import '../widgets/form/jam_session_general_section.dart';
import '../widgets/form/jam_session_location_section.dart';
import '../widgets/form/jam_session_schedule_section.dart';
import '../widgets/form/jam_session_venue_section.dart';

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
    if (selectedId.isEmpty) {
      return null;
    }
    for (final venue in venues) {
      if (venue.id == selectedId) {
        return venue;
      }
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
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

    final selectedVenue = _useRegisteredVenue
        ? _findSelectedVenue(venues)
        : null;
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

    final session = _controller.buildSession(
      ownerId: managerId,
      dateTime: dateTime,
      selectedTime: _selectedTime!,
      isPublic: _isPublic,
      useRegisteredVenue: _useRegisteredVenue,
      selectedVenue: selectedVenue,
    );

    context.read<JamSessionFormCubit>().saveSession(session);
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
                      final hasVenues = venues.isNotEmpty;
                      final locationReadOnly = _useRegisteredVenue && hasVenues;

                      return IgnorePointer(
                        ignoring: formState.isSaving,
                        child: AppCard(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (formState.isSaving)
                                  const LinearProgressIndicator(),
                                if (formState.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      formState.errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                JamSessionGeneralSection(
                                  titleController: _controller.titleController,
                                  descriptionController:
                                      _controller.descriptionController,
                                  requirementsController:
                                      _controller.requirementsController,
                                  requiredValidator:
                                      _controller.requiredValidator,
                                  requirementsValidator:
                                      _controller.requirementsValidator,
                                ),
                                const SizedBox(height: 16),
                                JamSessionScheduleSection(
                                  dateLabel: dateLabel,
                                  timeLabel: timeLabel,
                                  onPickDate: _pickDate,
                                  onPickTime: _pickTime,
                                ),
                                const SizedBox(height: 16),
                                JamSessionVenueSection(
                                  useRegisteredVenue: _useRegisteredVenue,
                                  isLoadingVenues: venuesState.isLoading,
                                  venuesError: venuesState.errorMessage,
                                  venues: venues,
                                  selectedVenueId: _selectedVenueId,
                                  onToggleUseRegisteredVenue: (value) {
                                    setState(() {
                                      _useRegisteredVenue = value;
                                      if (_useRegisteredVenue &&
                                          venues.isNotEmpty) {
                                        _selectedVenueId =
                                            _selectedVenueId ?? venues.first.id;
                                        final selected = _findSelectedVenue(
                                          venues,
                                        );
                                        if (selected != null) {
                                          _controller.applyVenueSelection(
                                            selected,
                                          );
                                        }
                                      }
                                    });
                                  },
                                  onVenueSelected: (value) {
                                    setState(() {
                                      _selectedVenueId = value;
                                      final selected = _findSelectedVenue(
                                        venues,
                                      );
                                      if (selected != null) {
                                        _controller.applyVenueSelection(
                                          selected,
                                        );
                                      }
                                    });
                                  },
                                  onRetryLoadVenues: () {
                                    context
                                        .read<VenuesCatalogCubit>()
                                        .loadSelectableVenues(refresh: true);
                                  },
                                ),
                                const SizedBox(height: 16),
                                JamSessionLocationSection(
                                  locationController:
                                      _controller.locationController,
                                  cityController: _controller.cityController,
                                  provinceController:
                                      _controller.provinceController,
                                  readOnly: locationReadOnly,
                                  requiredValidator:
                                      _controller.requiredValidator,
                                ),
                                const SizedBox(height: 16),
                                JamSessionComplianceSection(
                                  isPublic: _isPublic,
                                  onIsPublicChanged: (value) =>
                                      setState(() => _isPublic = value),
                                  maxAttendeesController:
                                      _controller.maxAttendeesController,
                                  entryFeeController:
                                      _controller.entryFeeController,
                                  ageRestrictionController:
                                      _controller.ageRestrictionController,
                                  optionalPositiveIntValidator:
                                      _controller.optionalPositiveIntValidator,
                                  optionalNonNegativeNumberValidator:
                                      _controller
                                          .optionalNonNegativeNumberValidator,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () => _saveSession(venues),
                                    child: Text(
                                      formState.isSaving
                                          ? 'Guardando...'
                                          : 'Guardar Jam Session',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
