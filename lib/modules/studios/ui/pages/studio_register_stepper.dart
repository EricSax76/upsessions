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
  });

  final int currentStep;
  final bool isSubmitting;
  final StudioRegisterFormController form;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: currentStep,
      onStepContinue: onStepContinue,
      onStepCancel: onStepCancel,
      steps: [
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
          state: currentStep > 0 ? StepState.complete : StepState.editing,
        ),
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
          state: currentStep == 1 ? StepState.editing : StepState.indexed,
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
                      : Text(currentStep == 0 ? 'Siguiente' : 'Registrar'),
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
