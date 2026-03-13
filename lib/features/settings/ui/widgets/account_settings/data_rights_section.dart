import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';

class DataRightsSection extends StatelessWidget {
  const DataRightsSection({
    required this.isRequestingDataExport,
    required this.onRequestDataExport,
    required this.isRequestingAccountDeletion,
    required this.onRequestAccountDeletion,
    required this.onContactDpo,
    super.key,
  });

  final bool isRequestingDataExport;
  final Future<void> Function() onRequestDataExport;
  final bool isRequestingAccountDeletion;
  final Future<void> Function() onRequestAccountDeletion;
  final Future<void> Function() onContactDpo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: isRequestingDataExport
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          title: const Text('Solicitar exportación de datos'),
          subtitle: const Text(
            'Ejercicio del derecho de acceso y portabilidad.',
          ),
          onTap: isRequestingDataExport
              ? null
              : () {
                  unawaited(onRequestDataExport());
                },
        ),
        ListTile(
          leading: isRequestingAccountDeletion
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
          title: const Text('Solicitar eliminación de cuenta'),
          subtitle: const Text('Ejercicio del derecho de supresión.'),
          onTap: isRequestingAccountDeletion
              ? null
              : () {
                  unawaited(onRequestAccountDeletion());
                },
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline),
          title: const Text('Contactar con privacidad (DPO)'),
          subtitle: Text(LegalPolicyRegistry.dpoEmail),
          onTap: () {
            unawaited(onContactDpo());
          },
        ),
      ],
    );
  }
}
