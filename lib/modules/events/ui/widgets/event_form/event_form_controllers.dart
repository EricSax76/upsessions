import 'package:flutter/material.dart';

import '../../../models/event_entity.dart';
import '../../../models/event_enums.dart';

class EventFormControllers {
  final title = TextEditingController();
  final city = TextEditingController();
  final venue = TextEditingController();
  final description = TextEditingController();
  final organizer = TextEditingController();
  final contactEmail = TextEditingController();
  final contactPhone = TextEditingController();
  final lineup = TextEditingController();
  final tags = TextEditingController();
  final ticket = TextEditingController();
  final capacity = TextEditingController();
  final resources = TextEditingController();
  final notes = TextEditingController();
  final province = TextEditingController();
  final postalCode = TextEditingController();
  final eventLicenseNumber = TextEditingController();
  final ticketPrice = TextEditingController();
  final vatRate = TextEditingController();
  final ageRestriction = TextEditingController();
  final accessibilityInfo = TextEditingController();
  final cancellationPolicy = TextEditingController();

  void dispose() {
    title.dispose();
    city.dispose();
    venue.dispose();
    description.dispose();
    organizer.dispose();
    contactEmail.dispose();
    contactPhone.dispose();
    lineup.dispose();
    tags.dispose();
    ticket.dispose();
    capacity.dispose();
    resources.dispose();
    notes.dispose();
    province.dispose();
    postalCode.dispose();
    eventLicenseNumber.dispose();
    ticketPrice.dispose();
    vatRate.dispose();
    ageRestriction.dispose();
    accessibilityInfo.dispose();
    cancellationPolicy.dispose();
  }

  EventEntity buildEvent({
    required String ownerId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required bool isPublic,
    required bool isFree,
  }) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    String? nullable(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    return EventEntity(
      id: '',
      ownerId: ownerId,
      title: title.text.trim(),
      city: city.text.trim(),
      venue: venue.text.trim(),
      start: start,
      end: end,
      description: description.text.trim(),
      organizer: organizer.text.trim(),
      contactEmail: contactEmail.text.trim(),
      contactPhone: contactPhone.text.trim(),
      lineup: _splitValues(lineup.text),
      tags: _splitValues(tags.text),
      ticketInfo: ticket.text.trim(),
      capacity: int.tryParse(capacity.text.trim()) ?? 0,
      resources: _splitValues(resources.text),
      notes: nullable(notes),
      province: nullable(province),
      postalCode: nullable(postalCode),
      eventLicenseNumber: nullable(eventLicenseNumber),
      ticketPrice: double.tryParse(ticketPrice.text.trim()),
      vatRate: double.tryParse(vatRate.text.trim()),
      isPublic: isPublic,
      ageRestriction: int.tryParse(ageRestriction.text.trim()),
      accessibilityInfo: nullable(accessibilityInfo),
      isFree: isFree,
      cancellationPolicy: nullable(cancellationPolicy),
      updatedAt: DateTime.now(),
      status: EventStatus.draft,
    );
  }

  static List<String> _splitValues(String input) {
    return input
        .split(RegExp(r'[,\n]'))
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
  }
}
