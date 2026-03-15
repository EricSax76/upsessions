import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../cubits/studios_status.dart';
import '../forms/studio_form_draft.dart';
import '../forms/studio_form_sections.dart';
import '../forms/studio_form_validator.dart';

class CreateStudioPage extends StatefulWidget {
  const CreateStudioPage({super.key, required this.ownerId});

  final String ownerId;

  @override
  State<CreateStudioPage> createState() => _CreateStudioPageState();
}

class _CreateStudioPageState extends State<CreateStudioPage> {
  final _formKey = GlobalKey<FormState>();
  final _draft = StudioFormDraft();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    return StudioFormValidator.required(value);
  }

  String? _positiveIntValidator(String? value) {
    return StudioFormValidator.positiveInt(value);
  }

  Future<void> _pickInsuranceExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _draft.insuranceExpiry ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _draft.insuranceExpiry = picked);
    }
  }

  void _submit() {
    final loc = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_draft.insuranceExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.studiosCreateInsuranceDateRequired)),
      );
      return;
    }

    if (_draft.parseMaxRoomCapacity() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.studiosCreateMaxCapacityInvalid)),
      );
      return;
    }

    final ownerId = widget.ownerId.trim();
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.studiosCreateAuthRequired)));
      return;
    }

    final studio = _draft.toStudioEntity(
      id: const Uuid().v4(),
      ownerId: ownerId,
    );

    context.read<MyStudioCubit>().createStudio(studio);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<MyStudioCubit, StudiosState>(
      listener: (context, state) {
        if (state.status == StudiosStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(loc.studiosCreateSuccess)));
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == StudiosStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.studiosCreateTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.studiosCreateSectionStudioData,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Studio Name',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name (Razon Social)',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.cifController,
                      decoration: const InputDecoration(labelText: 'CIF'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      loc.studiosCreateSectionLocation,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _draft.cityController,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad',
                            ),
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _draft.provinceController,
                            decoration: const InputDecoration(
                              labelText: 'Provincia',
                            ),
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _draft.postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Codigo postal',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      loc.studiosCreateSectionFiscal,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    StudioRegulatorySection(
                      draft: _draft,
                      requiredValidator: _requiredValidator,
                      positiveIntValidator: _positiveIntValidator,
                      onNoiseChanged: (value) => setState(
                        () => _draft.noiseOrdinanceCompliant = value,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      loc.studiosCreateSectionAccessibility,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    StudioAccessibilitySection(
                      draft: _draft,
                      requiredValidator: _requiredValidator,
                      onInsuranceExpiryTap: _pickInsuranceExpiry,
                      missingDateText: 'Seleccionar fecha',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(loc.studiosCreateAction),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
