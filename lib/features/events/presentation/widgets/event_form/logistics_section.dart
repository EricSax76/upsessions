import 'package:flutter/material.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_card.dart';
import 'event_form_field.dart';

class LogisticsSection extends StatelessWidget {
  const LogisticsSection({
    super.key,
    required this.lineupController,
    required this.resourcesController,
    required this.ticketController,
    required this.capacityController,
  });

  final TextEditingController lineupController;
  final TextEditingController resourcesController;
  final TextEditingController ticketController;
  final TextEditingController capacityController;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Logística y detalles',
      child: Column(
        children: [
          EventFormField(
            controller: lineupController,
            label: 'Lineup (separado por coma)',
            icon: Icons.group_work,
          ),
          const VSpace(12),
          EventFormField(
            controller: resourcesController,
            label: 'Recursos/Backline',
            icon: Icons.speaker,
          ),
          const VSpace(12),
          Row(
            children: [
              Expanded(
                child: EventFormField(
                  controller: ticketController,
                  label: 'Entradas/Aporte',
                  icon: Icons.confirmation_number,
                ),
              ),
              const HSpace(12),
              Expanded(
                child: EventFormField(
                  controller: capacityController,
                  label: 'Capacidad',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
