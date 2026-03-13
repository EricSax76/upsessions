import 'package:flutter/material.dart';

import 'studio_registration_coordinator.dart';

class StudioRegisterFormController {
  final accountFormKey = GlobalKey<FormState>();
  final studioFormKey = GlobalKey<FormState>();
  final locationFormKey = GlobalKey<FormState>();
  final regulatoryFormKey = GlobalKey<FormState>();
  final accessibilityFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final businessNameController = TextEditingController();
  final cifController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  // Normativa
  final vatNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final maxRoomCapacityController = TextEditingController();
  final accessibilityInfoController = TextEditingController();
  bool noiseOrdinanceCompliant = false;
  DateTime? insuranceExpiry;

  // Opening hours
  final Map<String, TextEditingController> openingHoursControllers = {
    'lun': TextEditingController(),
    'mar': TextEditingController(),
    'mie': TextEditingController(),
    'jue': TextEditingController(),
    'vie': TextEditingController(),
    'sab': TextEditingController(),
    'dom': TextEditingController(),
  };

  bool validateAccountStep() =>
      accountFormKey.currentState?.validate() ?? false;

  bool validateStudioStep() => studioFormKey.currentState?.validate() ?? false;

  bool validateLocationStep() =>
      locationFormKey.currentState?.validate() ?? false;

  bool validateRegulatoryStep() =>
      regulatoryFormKey.currentState?.validate() ?? false;

  bool validateAccessibilityStep() {
    if (insuranceExpiry == null) return false;
    return accessibilityFormKey.currentState?.validate() ?? false;
  }

  String? validateRequiredField(String? value) {
    if (value?.trim().isNotEmpty == true) {
      return null;
    }
    return 'Requerido';
  }

  String? validatePositiveIntField(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Requerido';
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Debe ser un entero mayor que 0';
    }
    return null;
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

  Map<String, String> buildOpeningHours() {
    final hours = <String, String>{};
    for (final entry in openingHoursControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        hours[entry.key] = value;
      }
    }
    return hours;
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
      // Normativa
      vatNumber: vatNumberController.text,
      licenseNumber: licenseNumberController.text,
      openingHours: buildOpeningHours(),
      city: cityController.text,
      province: provinceController.text,
      postalCode: postalCodeController.text,
      maxRoomCapacity: int.parse(maxRoomCapacityController.text.trim()),
      accessibilityInfo: accessibilityInfoController.text,
      noiseOrdinanceCompliant: noiseOrdinanceCompliant,
      insuranceExpiry: insuranceExpiry!,
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
    vatNumberController.dispose();
    licenseNumberController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    maxRoomCapacityController.dispose();
    accessibilityInfoController.dispose();
    for (final c in openingHoursControllers.values) {
      c.dispose();
    }
  }
}
