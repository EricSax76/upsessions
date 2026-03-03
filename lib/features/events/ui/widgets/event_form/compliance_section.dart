import 'package:flutter/material.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_card.dart';
import 'event_form_field.dart';

class ComplianceSection extends StatelessWidget {
  const ComplianceSection({
    super.key,
    required this.provinceController,
    required this.postalCodeController,
    required this.eventLicenseNumberController,
    required this.ticketPriceController,
    required this.vatRateController,
    required this.ageRestrictionController,
    required this.accessibilityInfoController,
    required this.cancellationPolicyController,
    required this.isPublic,
    required this.isFree,
    required this.onIsPublicChanged,
    required this.onIsFreeChanged,
  });

  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController eventLicenseNumberController;
  final TextEditingController ticketPriceController;
  final TextEditingController vatRateController;
  final TextEditingController ageRestrictionController;
  final TextEditingController accessibilityInfoController;
  final TextEditingController cancellationPolicyController;
  final bool isPublic;
  final bool isFree;
  final ValueChanged<bool> onIsPublicChanged;
  final ValueChanged<bool> onIsFreeChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Normativa y cumplimiento',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EventFormField(
                  controller: provinceController,
                  label: 'Provincia',
                  icon: Icons.map,
                ),
              ),
              const HSpace(12),
              Expanded(
                child: EventFormField(
                  controller: postalCodeController,
                  label: 'Código postal',
                  icon: Icons.local_post_office,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const VSpace(12),
          EventFormField(
            controller: eventLicenseNumberController,
            label: 'Nº licencia espectáculo',
            icon: Icons.verified,
          ),
          const VSpace(12),
          Row(
            children: [
              Expanded(
                child: EventFormField(
                  controller: ticketPriceController,
                  label: 'Precio entrada (€)',
                  icon: Icons.euro,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const HSpace(12),
              Expanded(
                child: EventFormField(
                  controller: vatRateController,
                  label: 'IVA (%)',
                  icon: Icons.receipt_long,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const VSpace(12),
          EventFormField(
            controller: ageRestrictionController,
            label: 'Edad mínima',
            icon: Icons.child_care,
            keyboardType: TextInputType.number,
          ),
          const VSpace(12),
          EventFormField(
            controller: accessibilityInfoController,
            label: 'Accesibilidad',
            icon: Icons.accessible,
            minLines: 2,
            maxLines: 3,
          ),
          const VSpace(12),
          EventFormField(
            controller: cancellationPolicyController,
            label: 'Política de cancelación',
            icon: Icons.policy,
            minLines: 2,
            maxLines: 3,
          ),
          const VSpace(12),
          SwitchListTile(
            title: const Text('Evento público'),
            subtitle: const Text('Visible para cualquier usuario'),
            value: isPublic,
            onChanged: (v) => onIsPublicChanged(v),
            secondary: const Icon(Icons.public),
          ),
          SwitchListTile(
            title: const Text('Evento gratuito'),
            subtitle: const Text('Sin coste de entrada'),
            value: isFree,
            onChanged: (v) => onIsFreeChanged(v),
            secondary: const Icon(Icons.money_off),
          ),
        ],
      ),
    );
  }
}
