import 'package:flutter/material.dart';
import 'package:upsessions/modules/event_manager/models/event_manager_entity.dart';

import 'manager_profile_helpers.dart';

class ManagerBasicDataCard extends StatelessWidget {
  const ManagerBasicDataCard({
    super.key,
    required this.manager,
    required this.nameController,
    required this.isBusy,
    required this.canSave,
    required this.onSave,
    required this.onNameChanged,
  });

  final EventManagerEntity manager;
  final TextEditingController nameController;
  final bool isBusy;
  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos básicos de registro',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              enabled: !isBusy,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => onNameChanged(),
              decoration: const InputDecoration(
                labelText: 'Nombre del manager / productora',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('email-${manager.contactEmail}'),
              initialValue: manager.contactEmail,
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Correo de registro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('phone-${manager.contactPhone}'),
              initialValue: manager.contactPhone,
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('city-${manager.id}-${managerCityLabel(manager)}'),
              initialValue: managerCityLabel(manager),
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave ? onSave : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(isBusy ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
