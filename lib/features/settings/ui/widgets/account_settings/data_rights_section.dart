import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';

class DataRightsSection extends StatelessWidget {
  const DataRightsSection({
    required this.isRequestingDataExport,
    required this.onRequestDataExport,
    required this.isRequestingAccountDeletion,
    required this.onRequestAccountDeletion,
    required this.requestingPrivacyRightType,
    required this.onRequestPrivacyRight,
    required this.onContactDpo,
    super.key,
  });

  final bool isRequestingDataExport;
  final Future<void> Function() onRequestDataExport;
  final bool isRequestingAccountDeletion;
  final Future<void> Function() onRequestAccountDeletion;
  final String? requestingPrivacyRightType;
  final Future<void> Function(String requestType, String title)
  onRequestPrivacyRight;
  final Future<void> Function() onContactDpo;

  static const List<_PrivacyRightItem> _privacyRights = [
    _PrivacyRightItem(
      requestType: 'access',
      icon: Icons.visibility_outlined,
      title: 'Solicitar acceso a datos',
      subtitle: 'Conocer qué datos tratamos y con qué finalidad.',
    ),
    _PrivacyRightItem(
      requestType: 'rectification',
      icon: Icons.edit_note_outlined,
      title: 'Solicitar rectificación',
      subtitle: 'Corregir datos inexactos o incompletos.',
    ),
    _PrivacyRightItem(
      requestType: 'restriction',
      icon: Icons.pause_circle_outline,
      title: 'Solicitar limitación del tratamiento',
      subtitle: 'Restringir temporalmente el uso de tus datos.',
    ),
    _PrivacyRightItem(
      requestType: 'objection',
      icon: Icons.block_outlined,
      title: 'Solicitar oposición al tratamiento',
      subtitle: 'Oponerte al tratamiento por motivos particulares.',
    ),
    _PrivacyRightItem(
      requestType: 'portability',
      icon: Icons.sync_alt_outlined,
      title: 'Solicitar portabilidad',
      subtitle: 'Recibir datos en formato estructurado y reutilizable.',
    ),
    _PrivacyRightItem(
      requestType: 'erasure',
      icon: Icons.delete_sweep_outlined,
      title: 'Solicitar supresión parcial de datos',
      subtitle: 'Eliminar datos concretos no necesarios para el servicio.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isRequestingAnyPrivacyRight = requestingPrivacyRightType != null;

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
          onTap: isRequestingDataExport || isRequestingAnyPrivacyRight
              ? null
              : () {
                  unawaited(onRequestDataExport());
                },
        ),
        for (final right in _privacyRights)
          ListTile(
            leading: requestingPrivacyRightType == right.requestType
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(right.icon),
            title: Text(right.title),
            subtitle: Text(right.subtitle),
            onTap: isRequestingAnyPrivacyRight
                ? null
                : () {
                    unawaited(
                      onRequestPrivacyRight(right.requestType, right.title),
                    );
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
          subtitle: const Text('Ejercicio del derecho de supresión total.'),
          onTap: isRequestingAccountDeletion || isRequestingAnyPrivacyRight
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

class _PrivacyRightItem {
  const _PrivacyRightItem({
    required this.requestType,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String requestType;
  final IconData icon;
  final String title;
  final String subtitle;
}
