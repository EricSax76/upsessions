import 'package:flutter/material.dart';

import '../../models/studio_entity.dart';
import 'studio_form_validator.dart';

class StudioFormDraft {
  StudioFormDraft() {
    _openingHoursControllers = {
      for (final day in _weekDays) day: TextEditingController(),
    };
  }

  static const List<String> _weekDays = [
    'lun',
    'mar',
    'mie',
    'jue',
    'vie',
    'sab',
    'dom',
  ];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cifController = TextEditingController();
  final businessNameController = TextEditingController();

  final vatNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final maxRoomCapacityController = TextEditingController();
  final accessibilityInfoController = TextEditingController();

  late final Map<String, TextEditingController> _openingHoursControllers;

  bool noiseOrdinanceCompliant = false;
  DateTime? insuranceExpiry;

  Map<String, TextEditingController> get openingHoursControllers =>
      _openingHoursControllers;

  void fillFromStudio(StudioEntity studio) {
    nameController.text = studio.name;
    descriptionController.text = studio.description;
    addressController.text = studio.address;
    emailController.text = studio.contactEmail;
    phoneController.text = studio.contactPhone;
    cifController.text = studio.cif;
    businessNameController.text = studio.businessName;

    vatNumberController.text = studio.vatNumber;
    licenseNumberController.text = studio.licenseNumber;
    cityController.text = studio.city;
    provinceController.text = studio.province;
    postalCodeController.text = studio.postalCode;
    maxRoomCapacityController.text = studio.maxRoomCapacity.toString();
    accessibilityInfoController.text = studio.accessibilityInfo;

    noiseOrdinanceCompliant = studio.noiseOrdinanceCompliant;
    insuranceExpiry = studio.insuranceExpiry;

    for (final controller in _openingHoursControllers.values) {
      controller.clear();
    }
    for (final entry in studio.openingHours.entries) {
      _openingHoursControllers[entry.key]?.text = entry.value;
    }
  }

  Map<String, String> buildOpeningHours() {
    final hours = <String, String>{};
    for (final entry in _openingHoursControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        hours[entry.key] = value;
      }
    }
    return hours;
  }

  int? parseMaxRoomCapacity() {
    return StudioFormValidator.parsePositiveInt(maxRoomCapacityController.text);
  }

  StudioEntity toStudioEntity({
    required String id,
    required String ownerId,
    String? logoUrl,
    String? bannerUrl,
    DateTime? updatedAt,
    bool isActive = true,
  }) {
    return StudioEntity(
      id: id,
      ownerId: ownerId,
      name: nameController.text,
      businessName: businessNameController.text,
      cif: cifController.text,
      description: descriptionController.text,
      address: addressController.text,
      contactEmail: emailController.text,
      contactPhone: phoneController.text,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      vatNumber: vatNumberController.text,
      licenseNumber: licenseNumberController.text,
      openingHours: buildOpeningHours(),
      city: cityController.text,
      province: provinceController.text,
      postalCode: postalCodeController.text,
      maxRoomCapacity: parseMaxRoomCapacity() ?? 1,
      accessibilityInfo: accessibilityInfoController.text,
      noiseOrdinanceCompliant: noiseOrdinanceCompliant,
      insuranceExpiry: insuranceExpiry ?? DateTime.now(),
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  StudioEntity applyToExisting(StudioEntity studio) {
    return studio.copyWith(
      name: nameController.text,
      description: descriptionController.text,
      address: addressController.text,
      contactPhone: phoneController.text,
      contactEmail: emailController.text,
      businessName: businessNameController.text,
      cif: cifController.text,
      vatNumber: vatNumberController.text,
      licenseNumber: licenseNumberController.text,
      openingHours: buildOpeningHours(),
      city: cityController.text,
      province: provinceController.text,
      postalCode: postalCodeController.text,
      maxRoomCapacity: parseMaxRoomCapacity() ?? studio.maxRoomCapacity,
      accessibilityInfo: accessibilityInfoController.text,
      noiseOrdinanceCompliant: noiseOrdinanceCompliant,
      insuranceExpiry: insuranceExpiry ?? studio.insuranceExpiry,
    );
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cifController.dispose();
    businessNameController.dispose();

    vatNumberController.dispose();
    licenseNumberController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    maxRoomCapacityController.dispose();
    accessibilityInfoController.dispose();

    for (final controller in _openingHoursControllers.values) {
      controller.dispose();
    }
  }
}
