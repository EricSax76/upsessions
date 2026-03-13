import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';

class LegalDocsSection extends StatelessWidget {
  const LegalDocsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.policy_outlined),
          title: const Text('Documentación legal'),
          subtitle: const Text(
            'Consulta términos, privacidad y política de cookies.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
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
        ),
      ],
    );
  }
}
