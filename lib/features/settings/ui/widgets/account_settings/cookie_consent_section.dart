import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';

class CookieConsentSection extends StatelessWidget {
  const CookieConsentSection({
    required this.cookiePreferences,
    required this.onAnalyticsCookiesChanged,
    required this.onPreferencesCookiesChanged,
    required this.onMarketingCookiesChanged,
    required this.userComplianceStream,
    required this.isUpdatingMarketingConsent,
    required this.onMarketingConsentChanged,
    super.key,
  });

  final CookieConsentPreferences cookiePreferences;
  final Future<void> Function(bool value) onAnalyticsCookiesChanged;
  final Future<void> Function(bool value) onPreferencesCookiesChanged;
  final Future<void> Function(bool value) onMarketingCookiesChanged;
  final Stream<DocumentSnapshot<Map<String, dynamic>>>? userComplianceStream;
  final bool isUpdatingMarketingConsent;
  final Future<void> Function(bool value) onMarketingConsentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('Cookies analíticas'),
          subtitle: const Text(
            'Puedes activarlas o retirarlas en cualquier momento.',
          ),
          value: cookiePreferences.analytics,
          onChanged: (value) {
            unawaited(onAnalyticsCookiesChanged(value));
          },
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('Cookies de preferencias'),
          subtitle: const Text('Guardan personalizaciones no esenciales.'),
          value: cookiePreferences.preferences,
          onChanged: (value) {
            unawaited(onPreferencesCookiesChanged(value));
          },
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('Cookies de marketing'),
          subtitle: const Text(
            'Controla personalización comercial y campañas.',
          ),
          value: cookiePreferences.marketing,
          onChanged: (value) {
            unawaited(onMarketingCookiesChanged(value));
          },
        ),
        if (userComplianceStream == null)
          const ListTile(
            leading: Icon(Icons.campaign_outlined),
            title: Text('Comunicaciones comerciales'),
            subtitle: Text('No disponible en este entorno.'),
          )
        else
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: userComplianceStream,
            builder: (context, snapshot) {
              final marketingConsent =
                  snapshot.data?.data()?['marketingConsent'] == true;
              return SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text('Comunicaciones comerciales'),
                subtitle: const Text(
                  'Recibe o revoca comunicaciones promocionales (LSSI).',
                ),
                value: marketingConsent,
                onChanged: isUpdatingMarketingConsent
                    ? null
                    : (value) {
                        unawaited(onMarketingConsentChanged(value));
                      },
              );
            },
          ),
      ],
    );
  }
}
