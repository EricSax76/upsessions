import 'package:flutter/material.dart';

import 'studio_registration_coordinator.dart';

class StudioRegisterFormController {
  final accountFormKey = GlobalKey<FormState>();
  final studioFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final businessNameController = TextEditingController();
  final cifController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  bool validateAccountStep() =>
      accountFormKey.currentState?.validate() ?? false;

  bool validateStudioStep() => studioFormKey.currentState?.validate() ?? false;

  String? validateRequiredField(String? value) {
    if (value?.trim().isNotEmpty == true) {
      return null;
    }
    return 'Requerido';
  }

  String? validateEmail(String? value) {
    if (value?.contains('@') == true) {
      return null;
    }
    return 'Email inválido';
  }

  String? validatePassword(String? value) {
    if ((value?.length ?? 0) >= 6) {
      return null;
    }
    return 'Mínimo 6 caracteres';
  }

  String? validatePasswordConfirmation(String? value) {
    if (value == passwordController.text) {
      return null;
    }
    return 'Las contraseñas no coinciden';
  }

  StudioRegistrationDraft buildDraft() {
    return StudioRegistrationDraft(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      businessName: businessNameController.text,
      cif: cifController.text,
      description: descriptionController.text,
      address: addressController.text,
      phone: phoneController.text,
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    businessNameController.dispose();
    cifController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
  }
}
