import 'package:flutter/material.dart';

import 'studio_register_form_controller.dart';

class StudioRegisterStepper extends StatelessWidget {
  const StudioRegisterStepper({
    super.key,
    required this.currentStep,
    required this.isSubmitting,
    required this.form,
    required this.onStepContinue,
    required this.onStepCancel,
    this.onNoiseOrdinanceChanged,
    this.onInsuranceExpiryTap,
  });

  final int currentStep;
  final bool isSubmitting;
  final StudioRegisterFormController form;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;
  final ValueChanged<bool>? onNoiseOrdinanceChanged;
  final VoidCallback? onInsuranceExpiryTap;

  static const int totalSteps = 5;

  StepState _stepState(int stepIndex) {
    if (currentStep > stepIndex) return StepState.complete;
    if (currentStep == stepIndex) return StepState.editing;
    return StepState.indexed;
  }

  String _continueLabel() {
    if (currentStep < totalSteps - 1) return 'Siguiente';
    return 'Registrar';
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: currentStep,
      onStepContinue: onStepContinue,
      onStepCancel: onStepCancel,
      steps: [
        // Step 0: Cuenta
        Step(
          title: const Text('Cuenta'),
          content: Form(
            key: form.accountFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: form.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                  ),
                  validator: form.validateEmail,
                ),
                TextFormField(
                  controller: form.passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: form.validatePassword,
                ),
                TextFormField(
                  controller: form.confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                  ),
                  obscureText: true,
                  validator: form.validatePasswordConfirmation,
                ),
              ],
            ),
          ),
          isActive: currentStep >= 0,
          state: _stepState(0),
        ),

        // Step 1: Datos del estudio
        Step(
          title: const Text('Datos'),
          content: Form(
            key: form.studioFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: form.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Comercial',
                  ),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.businessNameController,
                  decoration: const InputDecoration(labelText: 'Razón Social'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.cifController,
                  decoration: const InputDecoration(labelText: 'CIF'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.addressController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          isActive: currentStep >= 1,
          state: _stepState(1),
        ),

        // Step 2: Ubicación
        Step(
          title: const Text('Ubicación'),
          content: Form(
            key: form.locationFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: form.cityController,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.provinceController,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                  validator: form.validateRequiredField,
                ),
                TextFormField(
                  controller: form.postalCodeController,
                  decoration: const InputDecoration(labelText: 'Código postal'),
                  keyboardType: TextInputType.number,
                  validator: form.validateRequiredField,
                ),
              ],
            ),
          ),
          isActive: currentStep >= 2,
          state: _stepState(2),
        ),

        // Step 3: Normativa fiscal y administrativa
        Step(
          title: const Text('Normativa'),
          content: Form(
            key: form.regulatoryFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: form.vatNumberController,
                  decoration: const InputDecoration(
                    labelText: 'NIF-IVA (VAT Number)',
                    helperText: 'LIVA — facturas intracomunitarias',
                  ),
                  validator: form.validateRequiredField,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: form.licenseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Licencia municipal',
                    helperText:
                        'Reglamento espectáculos — licencia de actividad',
                  ),
                  validator: form.validateRequiredField,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: form.maxRoomCapacityController,
                  decoration: const InputDecoration(
                    labelText: 'Aforo máximo total',
                    helperText: 'Reglamento espectáculos — seguridad',
                  ),
                  keyboardType: TextInputType.number,
                  validator: form.validatePositiveIntField,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Cumplimiento normativa acústica'),
                  subtitle: const Text('Ordenanzas municipales de ruido'),
                  value: form.noiseOrdinanceCompliant,
                  onChanged: onNoiseOrdinanceChanged,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Horario de apertura (LSSI Art. 10)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...form.openingHoursControllers.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key.toUpperCase(),
                        hintText: '09:00–18:00',
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isActive: currentStep >= 3,
          state: _stepState(3),
        ),

        // Step 4: Accesibilidad y seguro
        Step(
          title: const Text('Accesibilidad'),
          content: Form(
            key: form.accessibilityFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: form.accessibilityInfoController,
                  decoration: const InputDecoration(
                    labelText: 'Información de accesibilidad',
                    helperText: 'RD 1/2013 (LIONDAU) — accesibilidad',
                  ),
                  maxLines: 3,
                  validator: form.validateRequiredField,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Caducidad seguro RC'),
                  subtitle: Text(
                    form.insuranceExpiry != null
                        ? '${form.insuranceExpiry!.day}/${form.insuranceExpiry!.month}/${form.insuranceExpiry!.year}'
                        : 'Seleccionar fecha (requerido)',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: onInsuranceExpiryTap,
                ),
              ],
            ),
          ),
          isActive: currentStep >= 4,
          state: _stepState(4),
        ),
      ],
      controlsBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onStepContinue,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_continueLabel()),
                ),
              ),
              if (currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: isSubmitting ? null : onStepCancel,
                  child: const Text('Atrás'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
