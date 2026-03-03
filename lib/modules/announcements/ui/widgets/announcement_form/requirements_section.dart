import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/announcement_enums.dart';

/// Sección del formulario de anuncio con los campos normativos adicionales:
/// tipo de contrato, método de contacto, caché, experiencia mínima y remoto.
class RequirementsSection extends StatelessWidget {
  const RequirementsSection({
    super.key,
    required this.budgetController,
    required this.experienceController,
    required this.selectedContactMethod,
    required this.selectedContractType,
    required this.locationRemote,
    required this.onContactMethodChanged,
    required this.onContractTypeChanged,
    required this.onLocationRemoteChanged,
  });

  final TextEditingController budgetController;
  final TextEditingController experienceController;
  final ContactMethod? selectedContactMethod;
  final AnnouncementContractType? selectedContractType;
  final bool locationRemote;
  final ValueChanged<ContactMethod?> onContactMethodChanged;
  final ValueChanged<AnnouncementContractType?> onContractTypeChanged;
  final ValueChanged<bool> onLocationRemoteChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Requisitos y condiciones',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tipo de contrato ──────────────────────────────────────
            DropdownButtonFormField<AnnouncementContractType>(
              initialValue: selectedContractType,
              decoration: InputDecoration(
                labelText: 'Tipo de relación (RD 1434/1992)',
                prefixIcon: const Icon(Icons.handshake_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: AnnouncementContractType.autonomo,
                  child: Text('Autónomo / Caché'),
                ),
                DropdownMenuItem(
                  value: AnnouncementContractType.contratoLaboralEspecial,
                  child: Text('Contrato laboral especial artistas'),
                ),
                DropdownMenuItem(
                  value: AnnouncementContractType.colaboracion,
                  child: Text('Colaboración / Sin retribución'),
                ),
              ],
              onChanged: onContractTypeChanged,
              hint: const Text('Selecciona tipo (opcional)'),
            ),
            const SizedBox(height: 12),

            // ── Método de contacto preferido ──────────────────────────
            DropdownButtonFormField<ContactMethod>(
              initialValue: selectedContactMethod,
              decoration: InputDecoration(
                labelText: 'Método de contacto preferido',
                prefixIcon: const Icon(Icons.contact_phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: ContactMethod.appMessage,
                  child: Text('Mensaje en la app'),
                ),
                DropdownMenuItem(
                  value: ContactMethod.email,
                  child: Text('Email'),
                ),
                DropdownMenuItem(
                  value: ContactMethod.phone,
                  child: Text('Teléfono'),
                ),
              ],
              onChanged: onContactMethodChanged,
              hint: const Text('Selecciona método (opcional)'),
            ),
            const SizedBox(height: 12),

            // ── Caché / Presupuesto ───────────────────────────────────
            TextFormField(
              controller: budgetController,
              decoration: InputDecoration(
                labelText: 'Caché / Presupuesto (ej. "300 €")',
                prefixIcon: const Icon(Icons.euro_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Experiencia mínima ────────────────────────────────────
            TextFormField(
              controller: experienceController,
              decoration: InputDecoration(
                labelText: 'Años de experiencia mínimos',
                prefixIcon: const Icon(Icons.timeline_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 4),

            // ── Remoto ───────────────────────────────────────────────
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.wifi_outlined),
              title: const Text('Acepta colaboración en remoto'),
              subtitle: const Text(
                'Grabación online, sesiones digitales, etc.',
              ),
              value: locationRemote,
              onChanged: onLocationRemoteChanged,
            ),
          ],
        ),
      ),
    );
  }
}
