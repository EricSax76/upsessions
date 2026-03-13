import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/repositories/auth_repository.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';

import '../../models/studio_entity.dart';

class CreateStudioPage extends StatefulWidget {
  const CreateStudioPage({super.key});

  @override
  State<CreateStudioPage> createState() => _CreateStudioPageState();
}

class _CreateStudioPageState extends State<CreateStudioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cifController = TextEditingController();
  final _businessNameController = TextEditingController();

  // Normativa
  final _vatNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _maxRoomCapacityController = TextEditingController();
  final _accessibilityInfoController = TextEditingController();
  bool _noiseOrdinanceCompliant = false;
  DateTime? _insuranceExpiry;

  // Opening hours: lun-dom
  final Map<String, TextEditingController> _openingHoursControllers = {
    'lun': TextEditingController(),
    'mar': TextEditingController(),
    'mie': TextEditingController(),
    'jue': TextEditingController(),
    'vie': TextEditingController(),
    'sab': TextEditingController(),
    'dom': TextEditingController(),
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cifController.dispose();
    _businessNameController.dispose();
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
      initialDate:
          _insuranceExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _insuranceExpiry = picked);
    }
  }

  String? _requiredValidator(String? value) =>
      value?.trim().isEmpty ?? true ? 'Required' : null;

  String? _positiveIntValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Required';
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Must be an integer greater than 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyStudioCubit, StudiosState>(
      listener: (context, state) {
        if (state.status == StudiosStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Studio created successfully!')),
          );
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
                'Register Studio',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Datos basicos ──────────────────────────────
                    Text(
                      'Datos del estudio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Studio Name',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name (Razón Social)',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cifController,
                      decoration: const InputDecoration(labelText: 'CIF'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),

                    // ── Ubicacion ─────────────────────────────────
                    const SizedBox(height: 32),
                    Text(
                      'Ubicación',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad',
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
                      ),
                      keyboardType: TextInputType.number,
                      validator: _requiredValidator,
                    ),

                    // ── Normativa fiscal ──────────────────────────
                    const SizedBox(height: 32),
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
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Licencia municipal',
                        helperText:
                            'Reglamento espectáculos — licencia de actividad',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxRoomCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Aforo máximo total',
                        helperText: 'Reglamento espectáculos — seguridad',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Cumplimiento normativa acústica'),
                      subtitle: const Text('Ordenanzas municipales de ruido'),
                      value: _noiseOrdinanceCompliant,
                      onChanged: (v) =>
                          setState(() => _noiseOrdinanceCompliant = v),
                    ),

                    // ── Accesibilidad y seguro ────────────────────
                    const SizedBox(height: 32),
                    Text(
                      'Accesibilidad y seguro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accessibilityInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Información de accesibilidad',
                        helperText:
                            'RD 1/2013 (LIONDAU) — accesibilidad para personas con discapacidad',
                      ),
                      maxLines: 3,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Caducidad seguro RC'),
                      subtitle: Text(
                        _insuranceExpiry != null
                            ? '${_insuranceExpiry!.day}/${_insuranceExpiry!.month}/${_insuranceExpiry!.year}'
                            : 'Seleccionar fecha',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickInsuranceExpiry,
                    ),

                    // ── Horario ───────────────────────────────────
                    const SizedBox(height: 32),
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
                          ),
                        ),
                      ),
                    ),

                    // ── Submit ─────────────────────────────────────
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          if (_insuranceExpiry == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selecciona la fecha de caducidad del seguro RC',
                                ),
                              ),
                            );
                            return;
                          }

                          final maxRoomCapacity = int.tryParse(
                            _maxRoomCapacityController.text.trim(),
                          );
                          if (maxRoomCapacity == null || maxRoomCapacity <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Aforo máximo inválido (debe ser > 0)',
                                ),
                              ),
                            );
                            return;
                          }

                          final authRepo = locate<AuthRepository>();
                          final currentUser = authRepo.currentUser;
                          final ownerId = currentUser?.id ?? 'mock_user_id';

                          final studio = StudioEntity(
                            id: const Uuid().v4(),
                            ownerId: ownerId,
                            name: _nameController.text,
                            businessName: _businessNameController.text,
                            cif: _cifController.text,
                            description: _descriptionController.text,
                            address: _addressController.text,
                            contactEmail: _emailController.text,
                            contactPhone: _phoneController.text,
                            // Normativa
                            vatNumber: _vatNumberController.text,
                            licenseNumber: _licenseNumberController.text,
                            openingHours: _buildOpeningHours(),
                            city: _cityController.text,
                            province: _provinceController.text,
                            postalCode: _postalCodeController.text,
                            maxRoomCapacity: maxRoomCapacity,
                            accessibilityInfo:
                                _accessibilityInfoController.text,
                            noiseOrdinanceCompliant: _noiseOrdinanceCompliant,
                            insuranceExpiry: _insuranceExpiry!,
                          );

                          context.read<MyStudioCubit>().createStudio(studio);
                        },
                        child: const Text('Create Studio'),
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
