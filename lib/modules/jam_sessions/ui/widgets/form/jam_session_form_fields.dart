import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../../venues/models/venue_entity.dart';
import '../../controllers/jam_session_form_controller.dart';
import 'jam_session_compliance_section.dart';
import 'jam_session_general_section.dart';
import 'jam_session_location_section.dart';
import 'jam_session_schedule_section.dart';
import 'jam_session_venue_section.dart';

class JamSessionFormFields extends StatelessWidget {
  const JamSessionFormFields({
    super.key,
    required this.controller,
    required this.isSaving,
    required this.formError,
    required this.venues,
    required this.isLoadingVenues,
    required this.venuesError,
    required this.dateLabel,
    required this.timeLabel,
    required this.isPublic,
    required this.useRegisteredVenue,
    required this.selectedVenueId,
    required this.locationReadOnly,
    required this.onPickDate,
    required this.onPickTime,
    required this.onIsPublicChanged,
    required this.onToggleUseRegisteredVenue,
    required this.onVenueSelected,
    required this.onRetryLoadVenues,
    required this.onSave,
  });

  final JamSessionFormController controller;
  final bool isSaving;
  final String? formError;
  final List<VenueEntity> venues;
  final bool isLoadingVenues;
  final String? venuesError;
  final String dateLabel;
  final String timeLabel;
  final bool isPublic;
  final bool useRegisteredVenue;
  final String? selectedVenueId;
  final bool locationReadOnly;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<bool> onIsPublicChanged;
  final ValueChanged<bool> onToggleUseRegisteredVenue;
  final ValueChanged<String?> onVenueSelected;
  final VoidCallback onRetryLoadVenues;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isSaving,
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSaving) const LinearProgressIndicator(),
              if (formError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    formError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              JamSessionGeneralSection(
                titleController: controller.titleController,
                descriptionController: controller.descriptionController,
                requirementsController: controller.requirementsController,
                requiredValidator: controller.requiredValidator,
                requirementsValidator: controller.requirementsValidator,
              ),
              const SizedBox(height: 16),
              JamSessionScheduleSection(
                dateLabel: dateLabel,
                timeLabel: timeLabel,
                onPickDate: onPickDate,
                onPickTime: onPickTime,
              ),
              const SizedBox(height: 16),
              JamSessionVenueSection(
                useRegisteredVenue: useRegisteredVenue,
                isLoadingVenues: isLoadingVenues,
                venuesError: venuesError,
                venues: venues,
                selectedVenueId: selectedVenueId,
                onToggleUseRegisteredVenue: onToggleUseRegisteredVenue,
                onVenueSelected: onVenueSelected,
                onRetryLoadVenues: onRetryLoadVenues,
              ),
              const SizedBox(height: 16),
              JamSessionLocationSection(
                locationController: controller.locationController,
                cityController: controller.cityController,
                provinceController: controller.provinceController,
                readOnly: locationReadOnly,
                requiredValidator: controller.requiredValidator,
              ),
              const SizedBox(height: 16),
              JamSessionComplianceSection(
                isPublic: isPublic,
                onIsPublicChanged: onIsPublicChanged,
                maxAttendeesController: controller.maxAttendeesController,
                entryFeeController: controller.entryFeeController,
                ageRestrictionController: controller.ageRestrictionController,
                optionalPositiveIntValidator:
                    controller.optionalPositiveIntValidator,
                optionalNonNegativeNumberValidator:
                    controller.optionalNonNegativeNumberValidator,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSave,
                  child: Text(isSaving ? 'Guardando...' : 'Guardar Jam Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
