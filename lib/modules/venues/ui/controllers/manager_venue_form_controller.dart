import 'package:flutter/material.dart';

import '../../models/venue_entity.dart';

class ManagerVenueFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final postalCodeController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final maxCapacityController = TextEditingController();
  final accessibilityInfoController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    licenseNumberController.dispose();
    maxCapacityController.dispose();
    accessibilityInfoController.dispose();
  }

  void hydrateFromVenue(VenueEntity venue) {
    nameController.text = venue.name;
    descriptionController.text = venue.description;
    addressController.text = venue.address;
    cityController.text = venue.city;
    provinceController.text = venue.province;
    postalCodeController.text = venue.postalCode ?? '';
    contactEmailController.text = venue.contactEmail;
    contactPhoneController.text = venue.contactPhone;
    licenseNumberController.text = venue.licenseNumber;
    maxCapacityController.text = venue.maxCapacity > 0
        ? venue.maxCapacity.toString()
        : '';
    accessibilityInfoController.text = venue.accessibilityInfo;
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requerido';
    }
    return null;
  }

  String? emailValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Requerido';
    if (!text.contains('@') || text.startsWith('@') || text.endsWith('@')) {
      return 'Email no válido';
    }
    return null;
  }

  String? positiveIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Requerido';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Debe ser un entero > 0';
    }
    return null;
  }

  VenueEntity buildVenue({
    required String ownerId,
    required bool isPublic,
    required VenueEntity? initialVenue,
  }) {
    final capacity = int.tryParse(maxCapacityController.text.trim()) ?? 0;

    return VenueEntity(
      id: initialVenue?.id ?? '',
      ownerId: ownerId,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      province: provinceController.text.trim(),
      postalCode: _trimToNull(postalCodeController.text),
      contactEmail: contactEmailController.text.trim(),
      contactPhone: contactPhoneController.text.trim(),
      licenseNumber: licenseNumberController.text.trim(),
      maxCapacity: capacity,
      accessibilityInfo: accessibilityInfoController.text.trim(),
      isPublic: isPublic,
      isActive: initialVenue?.isActive ?? true,
      sourceType: initialVenue?.sourceType ?? VenueSourceType.native,
      sourceId: initialVenue?.sourceId,
      createdAt: initialVenue?.createdAt,
      updatedAt: initialVenue?.updatedAt,
    );
  }

  String? _trimToNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }
}
