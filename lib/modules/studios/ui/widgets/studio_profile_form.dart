import 'package:flutter/material.dart';
import '../../models/studio_entity.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _businessNameController;
  late TextEditingController _cifController;

  // Normativa
  late TextEditingController _vatNumberController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _postalCodeController;
  late TextEditingController _maxRoomCapacityController;
  late TextEditingController _accessibilityInfoController;
  late bool _noiseOrdinanceCompliant;
  late DateTime _insuranceExpiry;
  late Map<String, TextEditingController> _openingHoursControllers;

  String? _studioId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _businessNameController = TextEditingController();
    _cifController = TextEditingController();

    // Normativa
    _vatNumberController = TextEditingController();
    _licenseNumberController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _postalCodeController = TextEditingController();
    _maxRoomCapacityController = TextEditingController();
    _accessibilityInfoController = TextEditingController();
    _noiseOrdinanceCompliant = false;
    _insuranceExpiry = DateTime.now();
    _openingHoursControllers = {
      'lun': TextEditingController(),
      'mar': TextEditingController(),
      'mie': TextEditingController(),
      'jue': TextEditingController(),
      'vie': TextEditingController(),
      'sab': TextEditingController(),
      'dom': TextEditingController(),
    };

    _syncControllers(widget.studio);
  }

  @override
  void didUpdateWidget(covariant StudioProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studio != oldWidget.studio) {
      _syncControllers(widget.studio);
    }
  }

  void _syncControllers(StudioEntity studio) {
    if (_studioId == studio.id) return;
    _studioId = studio.id;

    if (_nameController.text != studio.name) _nameController.text = studio.name;
    if (_descriptionController.text != studio.description) {
      _descriptionController.text = studio.description;
    }
    if (_addressController.text != studio.address) {
      _addressController.text = studio.address;
    }
    if (_phoneController.text != studio.contactPhone) {
      _phoneController.text = studio.contactPhone;
    }
    if (_emailController.text != studio.contactEmail) {
      _emailController.text = studio.contactEmail;
    }
    if (_businessNameController.text != studio.businessName) {
      _businessNameController.text = studio.businessName;
    }
    if (_cifController.text != studio.cif) _cifController.text = studio.cif;

    // Normativa
    _vatNumberController.text = studio.vatNumber;
    _licenseNumberController.text = studio.licenseNumber;
    _cityController.text = studio.city;
    _provinceController.text = studio.province;
    _postalCodeController.text = studio.postalCode;
    _maxRoomCapacityController.text = studio.maxRoomCapacity.toString();
    _accessibilityInfoController.text = studio.accessibilityInfo;
    _noiseOrdinanceCompliant = studio.noiseOrdinanceCompliant;
    _insuranceExpiry = studio.insuranceExpiry;

    for (final entry in studio.openingHours.entries) {
      _openingHoursControllers[entry.key]?.text = entry.value;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _cifController.dispose();
    _vatNumberController.dispose();
    _licenseNumberController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _maxRoomCapacityController.dispose();
    _accessibilityInfoController.dispose();
    for (final c in _openingHoursControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _buildOpeningHours() {
    final hours = <String, String>{};
    for (final entry in _openingHoursControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        hours[entry.key] = value;
      }
    }
    return hours;
  }

  Future<void> _pickInsuranceExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _insuranceExpiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _insuranceExpiry = picked);
    }
  }

  String? _requiredValidator(String? v) =>
      v?.trim().isNotEmpty == true ? null : 'Required';

  String? _positiveIntValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Required';
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Must be an integer greater than 0';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final maxRoomCapacity = int.tryParse(
        _maxRoomCapacityController.text.trim(),
      );
      if (maxRoomCapacity == null || maxRoomCapacity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aforo máximo inválido (debe ser > 0)')),
        );
        return;
      }

      final updatedStudio = widget.studio.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        contactPhone: _phoneController.text,
        contactEmail: _emailController.text,
        businessName: _businessNameController.text,
        cif: _cifController.text,
        // Normativa
        vatNumber: _vatNumberController.text,
        licenseNumber: _licenseNumberController.text,
        openingHours: _buildOpeningHours(),
        city: _cityController.text,
        province: _provinceController.text,
        postalCode: _postalCodeController.text,
        maxRoomCapacity: maxRoomCapacity,
        accessibilityInfo: _accessibilityInfoController.text,
        noiseOrdinanceCompliant: _noiseOrdinanceCompliant,
        insuranceExpiry: _insuranceExpiry,
      );
      widget.onSave(updatedStudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Basic Info ─────────────────────────────────
          Text('Basic Info', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Studio Name',
              border: OutlineInputBorder(),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          // ── Contact & Location ─────────────────────────
          const SizedBox(height: 24),
          Text(
            'Contact & Location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _provinceController,
                  decoration: const InputDecoration(
                    labelText: 'Provincia',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(
              labelText: 'Código postal',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),

          // ── Business Details ───────────────────────────
          const SizedBox(height: 24),
          Text(
            'Business Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cifController,
            decoration: const InputDecoration(
              labelText: 'CIF / Value ID',
              border: OutlineInputBorder(),
            ),
          ),

          // ── Normativa fiscal y administrativa ──────────
          const SizedBox(height: 24),
          Text(
            'Normativa fiscal y administrativa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vatNumberController,
            decoration: const InputDecoration(
              labelText: 'NIF-IVA (VAT Number)',
              helperText: 'LIVA — facturas intracomunitarias',
              border: OutlineInputBorder(),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _licenseNumberController,
            decoration: const InputDecoration(
              labelText: 'Licencia municipal',
              helperText: 'Reglamento espectáculos — licencia de actividad',
              border: OutlineInputBorder(),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _maxRoomCapacityController,
            decoration: const InputDecoration(
              labelText: 'Aforo máximo total',
              helperText: 'Reglamento espectáculos — seguridad',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _positiveIntValidator,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Cumplimiento normativa acústica'),
            subtitle: const Text('Ordenanzas municipales de ruido'),
            value: _noiseOrdinanceCompliant,
            onChanged: (v) => setState(() => _noiseOrdinanceCompliant = v),
          ),

          // ── Accesibilidad y seguro ─────────────────────
          const SizedBox(height: 24),
          Text(
            'Accesibilidad y seguro',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accessibilityInfoController,
            decoration: const InputDecoration(
              labelText: 'Información de accesibilidad',
              helperText: 'RD 1/2013 (LIONDAU)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Caducidad seguro RC'),
            subtitle: Text(
              '${_insuranceExpiry.day}/${_insuranceExpiry.month}/${_insuranceExpiry.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickInsuranceExpiry,
          ),

          // ── Horario ────────────────────────────────────
          const SizedBox(height: 24),
          Text(
            'Horario de apertura',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'LSSI Art. 10 — formato: 09:00–18:00',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ..._openingHoursControllers.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key.toUpperCase(),
                  hintText: '09:00–18:00',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),

          // ── Save ───────────────────────────────────────
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
