import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/manager_venue_form_cubit.dart';
import '../../cubits/manager_venue_form_state.dart';
import '../forms/venue_form_draft.dart';
import '../widgets/form/venue_basics_section.dart';
import '../widgets/form/venue_compliance_section.dart';
import '../widgets/form/venue_contact_section.dart';
import '../widgets/form/venue_location_section.dart';
import '../forms/venue_form_validator.dart';

class ManagerVenueFormPage extends StatefulWidget {
  const ManagerVenueFormPage({super.key});

  @override
  State<ManagerVenueFormPage> createState() => _ManagerVenueFormPageState();
}

class _ManagerVenueFormPageState extends State<ManagerVenueFormPage> {
  final _formKey = GlobalKey<FormState>();

  void _saveVenue() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ManagerVenueFormCubit>().saveVenue();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerVenueFormCubit, ManagerVenueFormState>(
      listenWhen: (previous, current) =>
          previous.saveSuccess != current.saveSuccess ||
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local guardado correctamente.')),
          );
          context.read<ManagerVenueFormCubit>().clearTransientFeedback();
          context.pop(true);
          return;
        }

        final message = state.feedbackMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context.read<ManagerVenueFormCubit>().clearTransientFeedback();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ManagerVenueFormCubit>();
        final draft = cubit.draft;
        final title = state.isEditing ? 'Editar Local' : 'Nuevo Local';

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: _buildBody(context, state, cubit, draft),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ManagerVenueFormState state,
    ManagerVenueFormCubit cubit,
    VenueFormDraft draft,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.loadingError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: cubit.retryLoad,
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
          child: IgnorePointer(
            ignoring: state.isSaving,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.isSaving) const LinearProgressIndicator(),
                  VenueBasicsSection(
                    nameController: draft.nameController,
                    descriptionController: draft.descriptionController,
                    requiredValidator: (value) =>
                        VenueFormValidator.required(value),
                  ),
                  const SizedBox(height: 16),
                  VenueLocationSection(
                    addressController: draft.addressController,
                    cityController: draft.cityController,
                    provinceController: draft.provinceController,
                    postalCodeController: draft.postalCodeController,
                    requiredValidator: (value) =>
                        VenueFormValidator.required(value),
                  ),
                  const SizedBox(height: 16),
                  VenueContactSection(
                    contactEmailController: draft.contactEmailController,
                    contactPhoneController: draft.contactPhoneController,
                    licenseNumberController: draft.licenseNumberController,
                    requiredValidator: (value) =>
                        VenueFormValidator.required(value),
                    emailValidator: (value) => VenueFormValidator.email(value),
                  ),
                  const SizedBox(height: 16),
                  VenueComplianceSection(
                    maxCapacityController: draft.maxCapacityController,
                    accessibilityInfoController:
                        draft.accessibilityInfoController,
                    isPublic: state.isPublic,
                    onIsPublicChanged: cubit.setIsPublic,
                    requiredValidator: (value) =>
                        VenueFormValidator.required(value),
                    positiveIntValidator: (value) =>
                        VenueFormValidator.positiveInt(value),
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
          ),
        ),
      ),
    );
  }
}
