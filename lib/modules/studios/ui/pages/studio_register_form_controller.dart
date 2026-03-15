import 'package:flutter/material.dart';

import '../forms/studio_form_draft.dart';
import '../forms/studio_form_validator.dart';
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

  final studioDraft = StudioFormDraft();

  TextEditingController get nameController => studioDraft.nameController;
  TextEditingController get businessNameController =>
      studioDraft.businessNameController;
  TextEditingController get cifController => studioDraft.cifController;
  TextEditingController get descriptionController =>
      studioDraft.descriptionController;
  TextEditingController get addressController => studioDraft.addressController;
  TextEditingController get phoneController => studioDraft.phoneController;

  TextEditingController get vatNumberController =>
      studioDraft.vatNumberController;
  TextEditingController get licenseNumberController =>
      studioDraft.licenseNumberController;
  TextEditingController get cityController => studioDraft.cityController;
  TextEditingController get provinceController =>
      studioDraft.provinceController;
  TextEditingController get postalCodeController =>
      studioDraft.postalCodeController;
  TextEditingController get maxRoomCapacityController =>
      studioDraft.maxRoomCapacityController;
  TextEditingController get accessibilityInfoController =>
      studioDraft.accessibilityInfoController;

  Map<String, TextEditingController> get openingHoursControllers =>
      studioDraft.openingHoursControllers;

  bool get noiseOrdinanceCompliant => studioDraft.noiseOrdinanceCompliant;
  set noiseOrdinanceCompliant(bool value) {
    studioDraft.noiseOrdinanceCompliant = value;
  }

  DateTime? get insuranceExpiry => studioDraft.insuranceExpiry;
  set insuranceExpiry(DateTime? value) {
    studioDraft.insuranceExpiry = value;
  }

  bool validateAccountStep() =>
      accountFormKey.currentState?.validate() ?? false;

  bool validateStudioStep() => studioFormKey.currentState?.validate() ?? false;

  bool validateLocationStep() =>
      locationFormKey.currentState?.validate() ?? false;

  bool validateRegulatoryStep() =>
      regulatoryFormKey.currentState?.validate() ?? false;

  bool validateAccessibilityStep() {
    if (studioDraft.insuranceExpiry == null) return false;
    return accessibilityFormKey.currentState?.validate() ?? false;
  }

  String? validateRequiredField(String? value) {
    return StudioFormValidator.required(value, message: 'Requerido');
  }

  String? validatePositiveIntField(String? value) {
    return StudioFormValidator.positiveInt(
      value,
      requiredMessage: 'Requerido',
      invalidMessage: 'Debe ser un entero mayor que 0',
    );
  }

  String? validateEmail(String? value) {
    if (value?.contains('@') == true) {
      return null;
    }
    return 'Email invalido';
  }

  String? validatePassword(String? value) {
    if ((value?.length ?? 0) >= 6) {
      return null;
    }
    return 'Minimo 6 caracteres';
  }

  String? validatePasswordConfirmation(String? value) {
    if (value == passwordController.text) {
      return null;
    }
    return 'Las contrasenas no coinciden';
  }

  StudioRegistrationDraft buildDraft() {
    final maxRoomCapacity = studioDraft.parseMaxRoomCapacity() ?? 1;

    return StudioRegistrationDraft(
      email: emailController.text,
      password: passwordController.text,
      name: studioDraft.nameController.text,
      businessName: studioDraft.businessNameController.text,
      cif: studioDraft.cifController.text,
      description: studioDraft.descriptionController.text,
      address: studioDraft.addressController.text,
      phone: studioDraft.phoneController.text,
      vatNumber: studioDraft.vatNumberController.text,
      licenseNumber: studioDraft.licenseNumberController.text,
      openingHours: studioDraft.buildOpeningHours(),
      city: studioDraft.cityController.text,
      province: studioDraft.provinceController.text,
      postalCode: studioDraft.postalCodeController.text,
      maxRoomCapacity: maxRoomCapacity,
      accessibilityInfo: studioDraft.accessibilityInfoController.text,
      noiseOrdinanceCompliant: studioDraft.noiseOrdinanceCompliant,
      insuranceExpiry: studioDraft.insuranceExpiry ?? DateTime.now(),
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    studioDraft.dispose();
  }
}
