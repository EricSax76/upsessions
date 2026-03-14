import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locator/locator.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../cubits/venue_form_cubit.dart';
import '../../cubits/venue_form_state.dart';
import '../../models/venue_entity.dart';
import '../../repositories/venues_repository.dart';
import '../controllers/manager_venue_form_controller.dart';
import '../widgets/form/venue_basics_section.dart';
import '../widgets/form/venue_compliance_section.dart';
import '../widgets/form/venue_contact_section.dart';
import '../widgets/form/venue_location_section.dart';

class ManagerVenueFormPage extends StatefulWidget {
  const ManagerVenueFormPage({super.key, this.venueId, this.initialVenue});

  final String? venueId;
  final VenueEntity? initialVenue;

  @override
  State<ManagerVenueFormPage> createState() => _ManagerVenueFormPageState();
}

class _ManagerVenueFormPageState extends State<ManagerVenueFormPage> {
  final _controller = ManagerVenueFormController();

  VenueEntity? _editingVenue;
  bool _isPublic = true;
  bool _isLoading = false;
  String? _loadingError;

  bool get _isEditing => _editingVenue != null;

  @override
  void initState() {
    super.initState();
    final initialVenue = widget.initialVenue;
    if (initialVenue != null) {
      _setEditingVenue(initialVenue);
      return;
    }

    final venueId = (widget.venueId ?? '').trim();
    if (venueId.isNotEmpty) {
      _loadVenue(venueId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setEditingVenue(VenueEntity venue) {
    _editingVenue = venue;
    _isPublic = venue.isPublic;
    _controller.hydrateFromVenue(venue);
  }

  Future<void> _loadVenue(String venueId) async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final venue = await locate<VenuesRepository>().getVenueById(venueId);
      if (venue == null) {
        throw Exception('Local no encontrado');
      }
      if (!mounted) return;
      setState(() {
        _setEditingVenue(venue);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingError = 'No se pudo cargar el local: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveVenue() {
    if (!_controller.formKey.currentState!.validate()) return;

    final managerId = locate<AuthRepository>().currentUser?.id ?? '';
    if (managerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para gestionar locales.'),
        ),
      );
      return;
    }

    if (_editingVenue?.isStudioBacked ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este local viene de studios y no se edita desde aquí.',
          ),
        ),
      );
      return;
    }

    final venue = _controller.buildVenue(
      ownerId: managerId,
      isPublic: _isPublic,
      initialVenue: _editingVenue,
    );

    context.read<VenueFormCubit>().saveVenue(venue);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar Local' : 'Nuevo Local';

    return BlocListener<VenueFormCubit, VenueFormState>(
      listenWhen: (previous, current) =>
          previous.success != current.success ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local guardado correctamente.')),
          );
          context.pop(true);
          return;
        }

        final message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadingError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  final venueId = (widget.venueId ?? '').trim();
                  if (venueId.isEmpty) return;
                  _loadVenue(venueId);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: BlocBuilder<VenueFormCubit, VenueFormState>(
            builder: (context, state) {
              return IgnorePointer(
                ignoring: state.isSaving,
                child: Form(
                  key: _controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.isSaving) const LinearProgressIndicator(),
                      VenueBasicsSection(
                        nameController: _controller.nameController,
                        descriptionController:
                            _controller.descriptionController,
                        requiredValidator: _controller.requiredValidator,
                      ),
                      const SizedBox(height: 16),
                      VenueLocationSection(
                        addressController: _controller.addressController,
                        cityController: _controller.cityController,
                        provinceController: _controller.provinceController,
                        postalCodeController: _controller.postalCodeController,
                        requiredValidator: _controller.requiredValidator,
                      ),
                      const SizedBox(height: 16),
                      VenueContactSection(
                        contactEmailController:
                            _controller.contactEmailController,
                        contactPhoneController:
                            _controller.contactPhoneController,
                        licenseNumberController:
                            _controller.licenseNumberController,
                        requiredValidator: _controller.requiredValidator,
                        emailValidator: _controller.emailValidator,
                      ),
                      const SizedBox(height: 16),
                      VenueComplianceSection(
                        maxCapacityController:
                            _controller.maxCapacityController,
                        accessibilityInfoController:
                            _controller.accessibilityInfoController,
                        isPublic: _isPublic,
                        onIsPublicChanged: (value) {
                          setState(() => _isPublic = value);
                        },
                        requiredValidator: _controller.requiredValidator,
                        positiveIntValidator: _controller.positiveIntValidator,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saveVenue,
                          child: Text(
                            state.isSaving ? 'Guardando...' : 'Guardar Local',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
