import 'package:flutter/material.dart';

import '../../../venues/models/venue_entity.dart';
import '../../models/jam_session_entity.dart';

class JamSessionFormController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final locationController = TextEditingController();
  final maxAttendeesController = TextEditingController();
  final entryFeeController = TextEditingController();
  final ageRestrictionController = TextEditingController();

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    provinceController.dispose();
    cityController.dispose();
    locationController.dispose();
    maxAttendeesController.dispose();
    entryFeeController.dispose();
    ageRestrictionController.dispose();
  }

  void applyVenueSelection(VenueEntity venue) {
    locationController.text = venue.name.trim();
    cityController.text = venue.city.trim();
    provinceController.text = venue.province.trim();
    if (maxAttendeesController.text.trim().isEmpty && venue.maxCapacity > 0) {
      maxAttendeesController.text = venue.maxCapacity.toString();
    }
  }

  List<String> parseRequirements(String raw) {
    return raw
        .split(RegExp(r'[,\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int? parseOptionalPositiveInt(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  double? parseOptionalNonNegativeDouble(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  String? trimToNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requerido';
    }
    return null;
  }

  String? optionalPositiveIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Introduce un numero entero mayor que 0';
    }
    return null;
  }

  String? optionalNonNegativeNumberValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) {
      return 'Introduce un numero valido (>= 0)';
    }
    return null;
  }

  String? requirementsValidator(String? value) {
    if (parseRequirements(value ?? '').isEmpty) {
      return 'Anade al menos un perfil';
    }
    return null;
  }

  JamSessionEntity buildSession({
    required String ownerId,
    required DateTime dateTime,
    required TimeOfDay selectedTime,
    required bool isPublic,
    required bool useRegisteredVenue,
    required VenueEntity? selectedVenue,
  }) {
    final requirements = parseRequirements(requirementsController.text);
    final maxAttendees = parseOptionalPositiveInt(maxAttendeesController.text);
    final entryFee = parseOptionalNonNegativeDouble(entryFeeController.text);
    final ageRestriction = parseOptionalPositiveInt(
      ageRestrictionController.text,
    );

    return JamSessionEntity(
      id: '',
      ownerId: ownerId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      date: dateTime,
      time: formatTime(selectedTime),
      location: useRegisteredVenue
          ? (selectedVenue?.name ?? '').trim()
          : locationController.text.trim(),
      city: useRegisteredVenue
          ? (selectedVenue?.city ?? '').trim()
          : cityController.text.trim(),
      instrumentRequirements: requirements,
      province: useRegisteredVenue
          ? trimToNull(selectedVenue?.province ?? '')
          : trimToNull(provinceController.text),
      maxAttendees:
          maxAttendees ??
          (useRegisteredVenue &&
                  selectedVenue != null &&
                  selectedVenue.maxCapacity > 0
              ? selectedVenue.maxCapacity
              : null),
      isPublic: isPublic,
      venueId: useRegisteredVenue ? selectedVenue?.id : null,
      entryFee: entryFee,
      ageRestriction: ageRestriction,
    );
  }
}
