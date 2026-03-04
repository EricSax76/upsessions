import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/features/legal/legal_policy_registry.dart';

class TermsPolicyPage extends StatelessWidget {
  const TermsPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Términos y condiciones',
      lastUpdated: LegalPolicyRegistry.lastUpdatedDateLabel,
      sections: [
        _LegalSection(
          heading: 'Objeto del servicio',
          body:
              'UPSESSIONS facilita la coordinación entre músicos, salas y promotores para ensayos, bolos y comunicaciones internas.',
        ),
        _LegalSection(
          heading: 'Cuenta y uso responsable',
          body:
              'La persona usuaria debe facilitar datos veraces, custodiar sus credenciales y usar la plataforma de forma lícita.',
        ),
        _LegalSection(
          heading: 'Normas de contenido',
          body:
              'No está permitido publicar contenido ilícito, suplantaciones, spam ni material que vulnere derechos de terceros.',
        ),
        _LegalSection(
          heading: 'Suspensión y baja',
          body:
              'Se podrá suspender o cerrar cuentas por incumplimiento grave de estas condiciones o por obligaciones legales.',
        ),
      ],
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Política de privacidad',
      lastUpdated: LegalPolicyRegistry.lastUpdatedDateLabel,
      sections: [
        _LegalSection(
          heading: 'Responsable y finalidad',
          body:
              'Tratamos datos para prestar el servicio, gestionar la seguridad de la cuenta y mantener la comunicación operativa de la plataforma.',
        ),
        _LegalSection(
          heading: 'Base jurídica',
          body:
              'El tratamiento principal se basa en la ejecución del contrato del servicio y, cuando corresponda, en consentimiento específico.',
        ),
        _LegalSection(
          heading: 'Conservación',
          body:
              'Los datos se conservan durante la vigencia de la cuenta y los plazos legales aplicables; tras baja se aplican periodos de supresión.',
        ),
        _LegalSection(
          heading: 'Derechos',
          body:
              'Puedes solicitar acceso, rectificación, supresión, limitación, oposición y portabilidad por los canales de soporte habilitados.',
        ),
      ],
    );
  }
}

class CookiesPolicyPage extends StatelessWidget {
  const CookiesPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScaffold(
      title: 'Política de cookies',
      lastUpdated: LegalPolicyRegistry.lastUpdatedDateLabel,
      sections: [
        _LegalSection(
          heading: 'Qué son las cookies',
          body:
              'Son pequeños archivos que se almacenan en tu navegador y permiten recordar opciones y medir uso del sitio.',
        ),
        _LegalSection(
          heading: 'Tipos que usamos',
          body:
              'Usamos cookies necesarias para seguridad y funcionamiento, y cookies opcionales para analítica, preferencias y marketing.',
        ),
        _LegalSection(
          heading: 'Gestión del consentimiento',
          body:
              'Puedes aceptar, rechazar o configurar categorías no necesarias desde el panel de “Privacidad y cookies”.',
        ),
        _LegalSection(
          heading: 'Cómo retirar el consentimiento',
          body:
              'La retirada se realiza desde el mismo panel, con efecto inmediato para nuevas operaciones de seguimiento.',
        ),
      ],
    );
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última actualización: $lastUpdated',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.legalTerms),
                        child: const Text('Términos'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.legalPrivacy),
                        child: const Text('Privacidad'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.legalCookies),
                        child: const Text('Cookies'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final section in sections) ...[
                    Text(
                      section.heading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(section.body),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}
