import 'package:flutter/material.dart';

import '../../models/venue_entity.dart';
import 'venue_form_validator.dart';

class VenueFormDraft {
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

  void fillFromVenue(VenueEntity venue) {
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

  VenueEntity toVenueEntity({
    required String ownerId,
    required bool isPublic,
    required VenueEntity? initialVenue,
  }) {
    final capacity =
        VenueFormValidator.parsePositiveInt(maxCapacityController.text) ?? 0;

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

  String? _trimToNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }
}
