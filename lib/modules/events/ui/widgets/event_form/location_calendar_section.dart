import 'package:flutter/material.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_card.dart';
import 'event_form_field.dart';
import 'picker_field.dart';

class LocationCalendarSection extends StatelessWidget {
  const LocationCalendarSection({
    super.key,
    required this.cityController,
    required this.venueController,
    required this.dateLabel,
    required this.startLabel,
    required this.endLabel,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  final TextEditingController cityController;
  final TextEditingController venueController;
  final String dateLabel;
  final String startLabel;
  final String endLabel;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Calendario y ubicación',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EventFormField(
                  controller: cityController,
                  label: 'Ciudad',
                  icon: Icons.location_city,
                  validator: (value) => value != null && value.trim().isNotEmpty
                      ? null
                      : 'Requerido',
                ),
              ),
              const HSpace(12),
              Expanded(
                child: EventFormField(
                  controller: venueController,
                  label: 'Venue',
                  icon: Icons.place,
                  validator: (value) => value != null && value.trim().isNotEmpty
                      ? null
                      : 'Requerido',
                ),
              ),
            ],
          ),
          const VSpace(12),
          PickerField(
            label: 'Fecha',
            value: dateLabel,
            onTap: onPickDate,
            icon: Icons.calendar_today,
          ),
          const VSpace(12),
          Row(
            children: [
              Expanded(
                child: PickerField(
                  label: 'Inicio',
                  value: startLabel,
                  onTap: onPickStartTime,
                  icon: Icons.access_time,
                ),
              ),
              const HSpace(12),
              Expanded(
                child: PickerField(
                  label: 'Fin',
                  value: endLabel,
                  onTap: onPickEndTime,
                  icon: Icons.access_time_filled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
