import 'package:flutter/material.dart';

import '../../models/studio_entity.dart';
import '../forms/studio_form_draft.dart';
import '../forms/studio_form_sections.dart';
import '../forms/studio_form_validator.dart';

class StudioProfileForm extends StatefulWidget {
  const StudioProfileForm({
    super.key,
    required this.studio,
    required this.onSave,
  });

  final StudioEntity studio;
  final ValueChanged<StudioEntity> onSave;

  @override
  State<StudioProfileForm> createState() => _StudioProfileFormState();
}

class _StudioProfileFormState extends State<StudioProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _draft = StudioFormDraft();

  String? _studioId;

  @override
  void initState() {
    super.initState();
    _syncDraft(widget.studio);
  }

  @override
  void didUpdateWidget(covariant StudioProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studio != oldWidget.studio) {
      _syncDraft(widget.studio);
    }
  }

  void _syncDraft(StudioEntity studio) {
    if (_studioId == studio.id) return;
    _studioId = studio.id;
    _draft.fillFromStudio(studio);
  }

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
    final initial =
        _draft.insuranceExpiry ?? DateTime.now().add(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _draft.insuranceExpiry = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_draft.parseMaxRoomCapacity() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aforo maximo invalido (debe ser > 0)')),
      );
      return;
    }

    if (_draft.insuranceExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha de caducidad del seguro RC'),
        ),
      );
      return;
    }

    final updatedStudio = _draft.applyToExisting(widget.studio);
    widget.onSave(updatedStudio);
  }

  @override
  Widget build(BuildContext context) {
    const outlinedBorder = OutlineInputBorder();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Info', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.nameController,
            decoration: const InputDecoration(
              labelText: 'Studio Name',
              border: outlinedBorder,
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: outlinedBorder,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Contact & Location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: outlinedBorder,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _draft.cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: outlinedBorder,
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
                    border: outlinedBorder,
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
              border: outlinedBorder,
            ),
            keyboardType: TextInputType.number,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.emailController,
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              border: outlinedBorder,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: outlinedBorder,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Business Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              border: outlinedBorder,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _draft.cifController,
            decoration: const InputDecoration(
              labelText: 'CIF / Value ID',
              border: outlinedBorder,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Normativa fiscal y administrativa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          StudioRegulatorySection(
            draft: _draft,
            requiredValidator: _requiredValidator,
            positiveIntValidator: _positiveIntValidator,
            onNoiseChanged: (value) =>
                setState(() => _draft.noiseOrdinanceCompliant = value),
            border: outlinedBorder,
          ),
          const SizedBox(height: 24),
          Text(
            'Accesibilidad y seguro',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          StudioAccessibilitySection(
            draft: _draft,
            requiredValidator: _requiredValidator,
            onInsuranceExpiryTap: _pickInsuranceExpiry,
            border: outlinedBorder,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
